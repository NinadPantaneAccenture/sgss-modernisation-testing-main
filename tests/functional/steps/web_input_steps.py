"""Data entry step implementations for  Web UI tests."""
from asyncio.log import logger

import asyncio
import logging
import os
import time

from behave import step
from behave.api.async_step import async_run_until_complete

from hamcrest import assert_that, has_item, equal_to, has_entries, is_
from playwright.async_api import expect, async_playwright

from pages.common_page import Common
from pages.login_page import LoginPage
from pages.landing_page import LandingPage
from pages.upload_page import UploadPage

from tests.functional.environment import BASE_URL

import random
import string

def generate_random_alphanumeric(length=8):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

@step('I fill in the form fields as follows')
async def step_fill_in_form_fields(context):
    for row in context.table:
        await asyncio.sleep(3)
        field_name = row[0]
        value = row[1]
        value = context.resolve_value(row[1])

        logging.info(f"Field '{field_name}' resolved value: {value}")

        locator = context.page.locator(f'[name="{field_name}"]')
        count = await locator.count()
        logging.info(f"Found {count} element(s) for name='{field_name}'")

        await locator.click()
        await locator.fill(value)
        await locator.press("Tab")
        await context.page.wait_for_timeout(150)


@step('I type "{value}" into the autocomplete field and select the result')
@async_run_until_complete
async def step_type_into_autocomplete_and_select(context, value):
    """Type a value into an accessible autocomplete field and press Enter to select
    the resulting option.

    Args:
        value: The text to type into the autocomplete input (e.g., "Smith")
    """
    try:
        field = context.page.locator('input[name="input-autocomplete"]')
        await field.wait_for(state="visible")
        await field.click()
        await field.fill(value)

        # Wait for the listbox to expand with a result
        await asyncio.sleep(0.5)
        listbox = context.page.locator('[id$="__listbox"]')
        await listbox.wait_for(state="visible")

        await asyncio.sleep(0.5)
        await field.press("Enter")
        logging.info(f"✅ Typed '{value}' into autocomplete field and selected result")

    except Exception as e:
        logging.error(f"❌ Failed to interact with autocomplete field: {e}")
        raise AssertionError(f"Failed to interact with autocomplete field: {e}") from e