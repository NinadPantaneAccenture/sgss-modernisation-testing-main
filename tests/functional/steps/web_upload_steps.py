"""Step implementations for file upload tests."""

from asyncio.log import logger
import logging
import time
import os

from behave import step
from behave.api.async_step import async_run_until_complete


from hamcrest import assert_that, has_item, equal_to, has_entries, is_
from playwright.async_api import expect, async_playwright

from pages.common_page import Common
from pages.upload_page import UploadPage


@step('I select a {test_file} file to upload via the web UI')
@step('I select an {test_file} file to upload via the web UI')
@async_run_until_complete
async def step_select_upload_files(context, test_file):
    """Step to select a specific file for upload."""
    time.sleep(15)
    common = Common(context.page, context)
    upload = UploadPage(context.page)

    file_map = upload.get_file_map()
    normalized_file = test_file.strip('"\'').lower()

    logger.info(f"UPLOAD context id: {id(context)}")
    
    if normalized_file not in file_map:
        available = ', '.join(file_map.keys())
        raise ValueError(
            f"❌ Test file '{test_file}' not recognized. "
            f"Available options: {available}"
        )
    
    test_file_path = file_map[normalized_file]
    
    # ← Store the filename on context so S3 verification step can use it
    filename = os.path.basename(test_file_path)
    context.s3_test_key = f"PreRegFileSrcWeb/{filename}"  # adjust prefix to match your S3 structure
    logger.info(f"📌 Stored s3_test_key on context: {context.s3_test_key}")

    await common.click_element("Choose File", file_to_upload=test_file_path)
    logging.info(f"📂 Selected and uploaded test file: {test_file_path}")


@step('I should see the following "{message_type}" message: "{expected_message}"')
@async_run_until_complete
async def step_verify_message(context, message_type, expected_message):
    """
    Generic step to verify upload messages (success or error).
    """
    page = context.page
    upload_page = UploadPage(page)

    visible = await upload_page.wait_for_message(expected_message)

    if not visible:
        raise AssertionError(
            f"Expected {message_type} message not displayed: '{expected_message}'"
        )