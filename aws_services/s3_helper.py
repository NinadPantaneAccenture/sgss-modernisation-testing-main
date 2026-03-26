import boto3
import json
import logging
from pathlib import Path
from botocore.exceptions import ClientError
from aws_services.aws_config import TestConfig

logger = logging.getLogger(__name__)

class S3Helper:
    """Helper class for S3 operations in Glue job testing"""
    
    def __init__(self, region_name='us-east-1'):
        # Initialize file map cache
        self._file_map = None
        
        # Use hardcoded credentials if provided
        if hasattr(TestConfig, 'AWS_ACCESS_KEY_ID') and TestConfig.AWS_ACCESS_KEY_ID:
            self.s3_client = boto3.client(
                's3',
                region_name=region_name,
                aws_access_key_id=TestConfig.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=TestConfig.AWS_SECRET_ACCESS_KEY
            )
            self.s3_resource = boto3.resource(
                's3',
                region_name=region_name,
                aws_access_key_id=TestConfig.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=TestConfig.AWS_SECRET_ACCESS_KEY
            )
        else:
            # Fall back to default credential chain (AWS CLI, env vars, IAM role)
            self.s3_client = boto3.client('s3', region_name=region_name)
            self.s3_resource = boto3.resource('s3', region_name=region_name)
    
    def get_file_map(self):
        """Load and cache the test file mapping."""
        if self._file_map is None:
            config_path = Path(__file__).parent.parent / "tests" / "test_data" / "test_file_mapping.json"
            with open(config_path) as f:
                config = json.load(f)
            
            base_path = config["base_path"]
            self._file_map = {
                name.lower(): f"{base_path}/{path}" 
                for name, path in config["files"].items()
            }
        return self._file_map
    
    def upload_file(self, local_file_path, bucket_name, s3_key):
        """
        Upload a file to S3
        
        Args:
            local_file_path: Local file path
            bucket_name: S3 bucket name
            s3_key: S3 object key
        
        Returns:
            bool: True if upload successful, False otherwise
        """
        try:
            self.s3_client.upload_file(str(local_file_path), bucket_name, s3_key)
            logger.info(f"Successfully uploaded {s3_key} to {bucket_name}")
            return True
        except ClientError as e:
            logger.error(f"Failed to upload file: {e}")
            return False
    
    def get_file_content(self, bucket_name, s3_key):
        """
        Get file content from S3
        
        Args:
            bucket_name: S3 bucket name
            s3_key: S3 object key
        
        Returns:
            str: File content as string
        """
        try:
            response = self.s3_client.get_object(Bucket=bucket_name, Key=s3_key)
            content = response['Body'].read().decode('utf-8')
            return content
        except ClientError as e:
            logger.error(f"Failed to get file content: {e}")
            return None
