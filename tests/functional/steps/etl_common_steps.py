
from behave import step
from behave.api.async_step import async_run_until_complete

from datetime import datetime
import boto3
import time
import logging

# Import your helper classes
import sys
import os
#project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
#sys.path.insert(0, project_root)

from aws_services.s3_helper import S3Helper
from aws_services.glue_helper import GlueHelper
from aws_services.aurora_helper import AuroraHelper
from aws_services.aws_config import TestConfig

logger = logging.getLogger(__name__)

#==================
# Background Steps
#==================

@step('the test environment is configured')
def step_validate_config(context):
    """Validate test configuration"""
    TestConfig.validate_config()
    
    # Initialize helpers
    context.s3_helper = S3Helper(region_name=TestConfig.AWS_REGION)
    context.glue_helper = GlueHelper(region_name=TestConfig.AWS_REGION)
    context.aurora_helper = AuroraHelper(
        #host=TestConfig.AURORA_HOST,
        database=TestConfig.AURORA_DATABASE,
        #user=TestConfig.AURORA_USER,
        #password=TestConfig.AURORA_PASSWORD,
        port=TestConfig.AURORA_PORT
    )
    
    # Store test data for verification
    context.test_data = []
    context.s3_test_key = None
    context.job_run_id = None

@step('I wait for the decryptor to process the file')
def step_wait_for_decryptor(context):
    """Wait 2 minutes for the decryptor to process the file"""
    import time
    
    logger.info("Waiting for decryptor to process the file...")
    time.sleep(20)  # 120 seconds = 2 minutes
    logger.info("Wait complete, now proceeding")
    

#==================================================================================================================================

@step('the transformed data in Aurora should have correct data types')
def step_verify_data_types(context):
    """Verify data types after transformation"""
    records = context.aurora_helper.get_records(TestConfig.AURORA_TABLE_NAME, limit=1)
    
    assert len(records) > 0, "No records found"
    
    record = records[0]
    # Verify types based on your transformation logic
    assert isinstance(record.get('amount'), (float, int)), "Amount should be numeric"
    print("Verified data types")


@step('the transformed data should have calculated fields')
def step_verify_calculated_fields(context):
    """Verify calculated/derived fields exist"""
    records = context.aurora_helper.get_records(TestConfig.AURORA_TABLE_NAME, limit=1)
    
    assert len(records) > 0, "No records found"
    
    # Verify calculated fields exist (adjust based on your schema)
    record = records[0]
    assert 'created_timestamp' in record, "Missing calculated timestamp field"
    print("Verified calculated fields")


@step('Aurora should contain the expected records')
def step_verify_expected_records(context):
    """Verify expected records exist in Aurora"""
    expected_count = len(context.test_data)
    actual_count = context.aurora_helper.get_row_count(TestConfig.AURORA_TABLE_NAME)
    assert actual_count == expected_count, f"Expected {expected_count} records, found {actual_count}"

@step('the Glue job should fail with an error')
def step_verify_job_failure(context):
    """Verify job failed"""
    assert not context.job_success, "Job should have failed but succeeded"
    assert context.job_status in ['FAILED', 'STOPPED'], f"Expected failure, got {context.job_status}"


@step('the job error message should contain "{text}"')
def step_verify_error_message(context, text):
    """Verify error message contains specific text"""
    error_msg = context.job_details.get('error_message', '').lower()
    assert text.lower() in error_msg, f"Error message doesn't contain '{text}': {error_msg}"


@step('Aurora should contain {expected_count:d} records in the test table')
def step_verify_record_count(context, expected_count):
    """Verify number of records in Aurora"""
    actual_count = context.aurora_helper.get_row_count(TestConfig.AURORA_TABLE_NAME)
    assert actual_count == expected_count, f"Expected {expected_count} records, found {actual_count}"
    print(f"Verified {actual_count} records in Aurora")