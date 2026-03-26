
from behave import step
from behave.api.async_step import async_run_until_complete


import logging
import time
from datetime import datetime
from pathlib import Path


from aws_services.s3_helper import S3Helper
from aws_services.glue_helper import GlueHelper
from aws_services.aurora_helper import AuroraHelper
from aws_services.aws_config import TestConfig

logger = logging.getLogger(__name__)



@step('a {test_file} test file is uploaded to the {folder_name} S3 folder')
@async_run_until_complete
async def step_select_upload_files(context, test_file, folder_name):
    """Step to select a specific file for upload to a designated S3 folder."""

    s3_helper = S3Helper()
    file_map = s3_helper.get_file_map()
    normalized_file = test_file.strip('"\'').lower()
    folder_name = folder_name.strip('"\'')
    
    #logger.info(f"📂 Folder name: '{folder_name}'")
    
    if normalized_file not in file_map:
        available = ', '.join(file_map.keys())
        raise ValueError(
            f"❌ Test file '{test_file}' not recognized. "
            f"Available options: {available}"
        )
    
    test_file_path = file_map[normalized_file]
    #logger.info(f"📄 Test file path from map: '{test_file_path}'")
    
    # Upload to S3
    # Navigate to project root (from tests/e2e/steps -> tests -> project root)
    local_file = Path(__file__).parent.parent.parent.parent / test_file_path
    #logger.info(f"📍 Local file path: '{local_file}'")
    #logger.info(f"📍 Local file exists: {local_file.exists()}")
    
    if not local_file.exists():
        raise FileNotFoundError(f"Test file not found at: {local_file}")
    
    # Generate S3 key using the specified folder name
    file_name = local_file.name
    s3_key = f"{folder_name}/{file_name}"
    
    #logger.info(f"🔑 Generated S3 key: '{s3_key}'")
    #logger.info(f"🪣 Target S3 bucket: '{TestConfig.S3_BUCKET_NAME}'")
    #logger.info(f"🌐 Full S3 path: s3://{TestConfig.S3_BUCKET_NAME}/{s3_key}")
    
    success = s3_helper.upload_file(
        local_file_path=local_file,
        bucket_name=TestConfig.S3_BUCKET_NAME,
        s3_key=s3_key
    )
    
    if not success:
        raise Exception(f"Failed to upload {file_name} to S3")
    
    # Store S3 key in context for later steps
    context.s3_test_key = s3_key
    
    logger.info(f"✅ Successfully uploaded '{test_file}' to S3 folder '{folder_name}': s3://{TestConfig.S3_BUCKET_NAME}/{s3_key}")


@step('I should see the uploaded file in the "{folder_name}" S3 folder')
@async_run_until_complete
async def step_verify_file_in_s3_folder(context, folder_name):
    """Step to verify that the uploaded file exists in the specified S3 folder."""
    logger.info(f"context.s3_test_key value: {getattr(context, 's3_test_key', 'MISSING')}")
    folder_name = folder_name.strip('"\'')
    
    # Get the S3 key from context (set in the upload step)
    if not hasattr(context, 's3_test_key'):
        raise AssertionError(
            "❌ No file has been uploaded yet. "
            "Please ensure the upload step is executed before this verification step."
        )
    
    s3_key = context.s3_test_key
    
    s3_helper = S3Helper()

    time.sleep(30)
    logger.info(f"VERIFY context id: {id(context)}")
    try:
        # Use head_object to check if the object exists
        s3_helper.s3_client.head_object(
            Bucket=TestConfig.S3_BUCKET_NAME,
            Key=s3_key
        )
        logger.info(f"✅ File '{s3_key}' verified in S3 bucket '{TestConfig.S3_BUCKET_NAME}'")
    except s3_helper.s3_client.exceptions.NoSuchKey:
        raise AssertionError(
            f"❌ File not found in S3: s3://{TestConfig.S3_BUCKET_NAME}/{s3_key}"
        )
    except Exception as e:
        raise AssertionError(
            f"❌ Error verifying file in S3: {e}"
        )