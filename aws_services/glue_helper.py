import boto3
import time
import logging
from botocore.exceptions import ClientError
from .aws_config import TestConfig

logger = logging.getLogger(__name__)

class GlueHelper:
    """Helper class for AWS Glue operations in testing"""
    
    def __init__(self, region_name='eu-west-2'):
        # Use hardcoded credentials if provided
        if hasattr(TestConfig, 'AWS_ACCESS_KEY_ID') and TestConfig.AWS_ACCESS_KEY_ID:
            self.glue_client = boto3.client(
                'glue',
                region_name=region_name,
                aws_access_key_id=TestConfig.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=TestConfig.AWS_SECRET_ACCESS_KEY
            )
        else:
            # Fall back to default credential chain
            self.glue_client = boto3.client('glue', region_name=region_name)
    
    def start_job_run(self, job_name, arguments=None):
        """
        Start a Glue job run
        
        Args:
            job_name: Name of the Glue job
            arguments: Dictionary of job arguments (optional)
        
        Returns:
            str: Job run ID if successful, None otherwise
        """
        try:
            params = {'JobName': job_name}
            if arguments:
                params['Arguments'] = arguments
            
            response = self.glue_client.start_job_run(**params)
            job_run_id = response['JobRunId']
            logger.info(f"Started Glue job '{job_name}' with run ID: {job_run_id}")
            return job_run_id
        except ClientError as e:
            logger.error(f"Failed to start job: {e}")
            return None
        
   
    
    def get_job_run_status(self, job_name, job_run_id):
        """
        Get the status of a Glue job run
        
        Args:
            job_name: Name of the Glue job
            job_run_id: Job run ID
        
        Returns:
            str: Job status (RUNNING, SUCCEEDED, FAILED, etc.)
        """
        try:
            response = self.glue_client.get_job_run(
                JobName=job_name,
                RunId=job_run_id
            )
            status = response['JobRun']['JobRunState']
            return status
        except ClientError as e:
            logger.error(f"Failed to get job status: {e}")
            return None
    
    def wait_for_job_completion(self, job_name, job_run_id, timeout=600, poll_interval=10):
        """
        Wait for a Glue job to complete
        
        Args:
            job_name: Name of the Glue job
            job_run_id: Job run ID
            timeout: Maximum time to wait in seconds (default 600)
            poll_interval: Time between status checks in seconds (default 10)
        
        Returns:
            tuple: (success: bool, final_status: str, details: dict)
        """
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            status = self.get_job_run_status(job_name, job_run_id)
            
            if status is None:
                return False, 'UNKNOWN', {}
            
            logger.info(f"Job {job_name} ({job_run_id}) status: {status}")
            
            if status == 'SUCCEEDED':
                details = self.get_job_run_details(job_name, job_run_id)
                return True, status, details
            elif status in ['FAILED', 'STOPPED', 'TIMEOUT']:
                details = self.get_job_run_details(job_name, job_run_id)
                return False, status, details
            
            time.sleep(poll_interval)
        
        logger.error(f"Job {job_name} timed out after {timeout} seconds")
        return False, 'TIMEOUT', {}
    
    def get_job_run_details(self, job_name, job_run_id):
        """
        Get detailed information about a job run
        
        Args:
            job_name: Name of the Glue job
            job_run_id: Job run ID
        
        Returns:
            dict: Job run details
        """
        try:
            response = self.glue_client.get_job_run(
                JobName=job_name,
                RunId=job_run_id
            )
            job_run = response['JobRun']
            
            details = {
                'job_name': job_run['JobName'],
                'run_id': job_run['Id'],
                'state': job_run['JobRunState'],
                'started_on': job_run.get('StartedOn'),
                'completed_on': job_run.get('CompletedOn'),
                'execution_time': job_run.get('ExecutionTime'),
                'error_message': job_run.get('ErrorMessage'),
                'log_group': job_run.get('LogGroupName')
            }
            
            return details
        except ClientError as e:
            logger.error(f"Failed to get job details: {e}")
            return {}
    
    def get_job_runs(self, job_name, max_results=10):
        """
        Get recent job runs for a job
        
        Args:
            job_name: Name of the Glue job
            max_results: Maximum number of runs to return
        
        Returns:
            list: List of job run details
        """
        try:
            response = self.glue_client.get_job_runs(
                JobName=job_name,
                MaxResults=max_results
            )
            return response['JobRuns']
        except ClientError as e:
            logger.error(f"Failed to get job runs: {e}")
            return []
    
    def stop_job_run(self, job_name, job_run_id):
        """
        Stop a running Glue job
        
        Args:
            job_name: Name of the Glue job
            job_run_id: Job run ID to stop
        
        Returns:
            bool: True if successful
        """
        try:
            self.glue_client.batch_stop_job_run(
                JobName=job_name,
                JobRunIds=[job_run_id]
            )
            logger.info(f"Stopped job run {job_run_id}")
            return True
        except ClientError as e:
            logger.error(f"Failed to stop job: {e}")
            return False
    
    def get_job_definition(self, job_name):
        """
        Get Glue job definition/configuration
        
        Args:
            job_name: Name of the Glue job
        
        Returns:
            dict: Job definition details
        """
        try:
            response = self.glue_client.get_job(Name=job_name)
            return response['Job']
        except ClientError as e:
            logger.error(f"Failed to get job definition: {e}")
            return {}
    
    def is_job_running(self, job_name):
        """
        Check if a job has any runs currently in RUNNING state
        
        Args:
            job_name: Name of the Glue job
        
        Returns:
            bool: True if job is currently running
        """
        runs = self.get_job_runs(job_name, max_results=5)
        for run in runs:
            if run['JobRunState'] == 'RUNNING':
                return True
        return False