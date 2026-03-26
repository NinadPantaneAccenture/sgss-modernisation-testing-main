
from behave import step
from behave.api.async_step import async_run_until_complete

from datetime import datetime
import boto3
import time
import logging


from aws_services.s3_helper import S3Helper
from aws_services.glue_helper import GlueHelper
from aws_services.aurora_helper import AuroraHelper
from aws_services.aws_config import TestConfig

logger = logging.getLogger(__name__)


@step('the Glue job is triggered to process the "{test_file}" file')
def step_trigger_glue_job(context, test_file):
    """Verify the event-driven Glue job will process the uploaded file"""
    import time

    # Since the job is event-driven, it should be triggered by the S3 upload
    # Wait for the job to start and reach RUNNING state
    max_wait_time = 180  # Maximum time to wait for job to start
    max_running_time = 300  # Maximum time job can be in RUNNING state (2 minutes)
    poll_interval = 4   # Check every n seconds
    elapsed_time = 0

    context.job_run_id = None
    job_start_time = None

    # First, wait for the job to start running
    while elapsed_time < max_wait_time:
        job_runs = context.glue_helper.get_job_runs(TestConfig.GLUE_JOB_NAME, max_results=1)

        if job_runs:
            latest_run = job_runs[0]
            job_state = latest_run.get('JobRunState')

            if job_state == 'RUNNING':
                context.job_run_id = latest_run['Id']
                job_start_time = time.time()

                # Get detailed information about the job run
                job_details = context.glue_helper.get_job_run_details(TestConfig.GLUE_JOB_NAME, context.job_run_id)

                logger.info(f"✅ Event-driven Glue job is now running")
                logger.info(f"   Job Run ID: {context.job_run_id}")
                logger.info(f"   Status: {job_state}")
                logger.info(f"   Started: {job_details.get('started_on')}")
                break
            else:
                logger.info(f"⏳ Previous job state is '{job_state}', waiting for new job run... ({elapsed_time}s elapsed)")

        time.sleep(poll_interval)
        elapsed_time += poll_interval
    else:
        # Timeout reached without job starting
        raise TimeoutError(f"Glue job did not reach RUNNING state within {max_wait_time} seconds")

    # Now monitor the running job and stop it if it runs too long
    while True:
        running_duration = time.time() - job_start_time
        
        if running_duration > max_running_time:
            logger.warning(f"⚠️  Job has been running for {running_duration:.1f}s (>{max_running_time}s), stopping job run...")
            if context.glue_helper.stop_job_run(TestConfig.GLUE_JOB_NAME, context.job_run_id):
                logger.info(f"✅ Successfully stopped job run {context.job_run_id}")
            else:
                logger.error(f"❌ Failed to stop job run {context.job_run_id}")
            raise TimeoutError(f"Glue job exceeded {max_running_time} second running threshold")
        
        # Check current status
        job_runs = context.glue_helper.get_job_runs(TestConfig.GLUE_JOB_NAME, max_results=1)
        if job_runs and job_runs[0]['Id'] == context.job_run_id:
            current_state = job_runs[0].get('JobRunState')
            
            # If job finished (successfully or not), exit the monitoring loop
            if current_state != 'RUNNING':
                logger.info(f"Job status changed to: {current_state}")
                break
        
        logger.info(f"⏳ Job still running... ({running_duration:.1f}s elapsed)")
        time.sleep(poll_interval)

    # Verify the test file will be processed by checking for the actual file name
    file_map = context.s3_helper.get_file_map()
    normalized_file = test_file.strip('"\'').lower()

    if normalized_file in file_map:
        file_path = file_map[normalized_file]
        # Extract just the file name from the path
        actual_file_name = file_path.split('/')[-1]

        assert actual_file_name in context.s3_test_key, \
            f"Expected file '{actual_file_name}' not found in S3 key: {context.s3_test_key}"
        logger.info(f"✅ Job will process file: {actual_file_name}")
    else:
        logger.warning(f"⚠️  Could not verify file - '{test_file}' not in mapping, but S3 key is: {context.s3_test_key}")

    # Store for later verification
    context.test_file_name = test_file


@step('I wait for the Glue job to complete')
def step_wait_for_completion(context):
    """Wait for Glue job to complete"""
    success, status, details = context.glue_helper.wait_for_job_completion(
        TestConfig.GLUE_JOB_NAME,
        context.job_run_id,
        timeout=TestConfig.GLUE_JOB_TIMEOUT,
        poll_interval=TestConfig.GLUE_POLL_INTERVAL
    )
    
    context.job_success = success
    context.job_status = status
    context.job_details = details
    
    print(f"Job completed with status: {status}")
    if details.get('error_message'):
        print(f"Error message: {details['error_message']}")


# Assertions

@step('the Glue job should complete with status "{expected_status}"')
def step_verify_job_status(context, expected_status):
    """Verify job completed with expected status"""
    actual_status = context.job_status
    
    assert actual_status == expected_status.upper(), \
        f"Expected status {expected_status.upper()}, got {actual_status}"
#==================================================================================================================================