"""Common step implementations for  Web UI tests."""
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


@step('I navigate to the landing page')
@step('I have navigated to the landing page')
@async_run_until_complete
async def step_navigate_to_landing_page(context):
    base_url = getattr(context, "base_url", BASE_URL)  # Let page object handle default
    landing_page = LandingPage(context.page, base_url)
    logging.info(f"Navigating to landing page: {landing_page.base_url}")
    await landing_page.go_to()
    logging.info("✅ Successfully reached the landing page.")


@step('I click the "{item}" button')
@step('I click the "{item}" link in the navigation menu')
@async_run_until_complete
async def click_item(context, item):
    """Click a button or navigation link by name."""
    await asyncio.sleep(0.75)  # Brief pause to allow page to settle before clicking
    try:
        await Common.click_element(context, item, retries=3)
    except Exception as e:
        raise AssertionError(f"Failed to click '{item}': {e}") from e


@step('I select "{option}" from the "{item}" dropdown')
@async_run_until_complete
async def select_dropdown_item(context, option, item):
    await asyncio.sleep(1)  # Brief pause to allow page to settle before interacting with dropdown
    """Select an option from a dropdown by name."""
    try:
        await Common.click_element(context, item, retries=3, select_option=option)
    except Exception as e:
        raise AssertionError(f"Failed to select '{option}' from '{item}': {e}") from e


@step('I select "{option}" from the dropdown')
@async_run_until_complete
async def select_ethnicity_dropdown(context, option):
    await asyncio.sleep(1)  # Brief pause to allow page to settle before interacting with dropdown
    """Select an option from the ethnicity dropdown by visible text or value."""
    try:
        select_element = await Common.find_element(context, "ethnicity")
        
        # Try matching by visible text first, then by value
        options = await select_element.query_selector_all("option")
        matched = False
        
        for opt in options:
            text = await opt.inner_text()
            value = await opt.get_attribute("value")
            
            if text.strip().upper() == option.strip().upper() or value == option:
                await select_element.select_option(value=value)
                matched = True
                break
        
        if not matched:
            raise ValueError(f"Option '{option}' not found in ethnicity dropdown")
            
    except Exception as e:
        raise AssertionError(f"Failed to select '{option}' from ethnicity dropdown: {e}") from e
    

@step('I enable the first checkbox')
@async_run_until_complete
async def click_checkbox(context):
    """Clicks the first checkbox on the page."""
    try:
        await Common.click_element(context, "checkbox")
    except Exception as e:
        raise AssertionError(f"Failed to click first checkbox: {e}") from e
    

@step('I enable the first two checkboxes')
@async_run_until_complete
async def enable_first_two_govuk_checkboxes(context):
    """Ensure the first two GOV.UK row checkboxes found on the page are in a checked state."""
    try:
        checkboxes = context.page.locator(
            'input[id^="checkbox-"].govuk-checkboxes__input[type="checkbox"]'
        )

        await checkboxes.nth(0).wait_for(state="visible", timeout=5000)
        await checkboxes.nth(1).wait_for(state="visible", timeout=5000)

        for i in range(2):
            checkbox = checkboxes.nth(i)
            if not await checkbox.is_checked():
                await checkbox.click()
            assert await checkbox.is_checked(), (
                f"Checkbox {i + 1} was not enabled after clicking"
            )

    except AssertionError:
        raise
    except Exception as e:
        raise AssertionError(f"Failed to enable first two checkboxes: {e}") from e
    
    
@step('I enable the first checkbox in the table')
@async_run_until_complete
async def enable_first_govuk_checkbox(context):
    """Ensure the first row checkbox found on the page is in a checked state."""
    try:
        checkbox = context.page.locator(
            'input[id^="checkbox-"].govuk-checkboxes__input[type="checkbox"]'
        ).first

        await checkbox.wait_for(state="visible", timeout=5000)

        if not await checkbox.is_checked():
            await Common.click_element(context, "govuk_checkbox_first")

        assert await checkbox.is_checked(), (
            "First GOV.UK checkbox was not enabled after clicking"
        )

        checkbox_id = await checkbox.get_attribute("id")         # e.g. "checkbox-5"
        context.selected_checkbox_id = checkbox_id              # "checkbox-5"
        context.selected_row_number = checkbox_id.split("-")[1]  # "5"
        context.deleted_record_id = context.selected_row_number  # used by removal verification step

    except AssertionError:
        raise
    except Exception as e:
        raise AssertionError(f"Failed to enable first checkbox: {e}") from e


@step('I click the checkbox for the first record in the "{tab_name}" tab')
@async_run_until_complete
async def click_checkbox_first_record(context, tab_name):
    """Click the checkbox for the first record in a tab and capture the record ID."""
    try:
        # Get the panel for this tab
        tab_selector = f"a[role='tab']:has-text('{tab_name}')"
        tab = context.page.locator(tab_selector)
        await tab.wait_for(state="visible", timeout=10000)
        
        # Click tab if not already active
        await tab.click()
        
        # Get panel ID
        panel_id = await tab.get_attribute("aria-controls")
        panel = context.page.locator(f"#{panel_id}")
        await panel.wait_for(state="visible", timeout=10000)
        
        # Get the first row in the table
        first_row = panel.locator("table tbody tr").first
        await first_row.wait_for(state="visible", timeout=10000)
        
        # Get all cells in the first row
        cells = first_row.locator("td")
        cell_count = await cells.count()
        logging.info(f"First row has {cell_count} cells")
        
        # The Specimen Request ID is in the second cell (after checkbox)
        # Cell structure: [checkbox cell, Specimen Request ID, Specimen number, ...]
        if cell_count < 2:
            raise ValueError(f"Expected at least 2 cells in row, got {cell_count}")
        
        # Get the second cell (Specimen Request ID column)
        specimen_request_cell = cells.nth(1)
        record_id = (await specimen_request_cell.inner_text()).strip()
        
        logging.info(f"Extracted Specimen Request ID: {record_id}")
        
        if not record_id:
            raise ValueError("Specimen Request ID is empty")
        
        # Store in context for later verification
        context.deleted_record_id = record_id
        logging.info(f"✅ Captured Specimen Request ID for deletion: {record_id}")
        
        # Click the checkbox in the first column
        checkbox = first_row.locator("input[type='checkbox']").first
        await checkbox.wait_for(state="visible", timeout=10000)
        await checkbox.click()
        logging.info(f"✅ Clicked checkbox for Specimen Request ID '{record_id}' in '{tab_name}' tab")
        
    except Exception as e:
        logging.error(f"Failed to click checkbox: {e}")
        raise AssertionError(f"Failed to click checkbox for first record in '{tab_name}': {e}") from e


@step('the page heading "{expected_txt}" is displayed')
@async_run_until_complete
async def check_heading_text(context, expected_txt):
    """Verify that the expected heading is visible on the page."""
    common = Common(
        context.page,
        base_url=getattr(context, "base_url", None),
        context=context,
        element_timeout=getattr(context, "element_timeout", 10000)
    )

    is_visible = await common.heading_is_displayed(expected_txt)
    assert_that(
        is_visible,
        is_(True),
        f"❌ Expected heading '{expected_txt}' not found on page."
    )


@step('I navigate to the {item} page')
@async_run_until_complete
async def step_navigate_to_specific_page(context, item):
   context.element_timeout = 5000
   try:
       await context.page.goto(f"{context.base_url}/{item}", wait_until='domcontentloaded', timeout=60000)
       logging.info(f"✅ Successfully navigated to the {item} page.")
   except Exception as e:
       logging.error(f"Navigation failed to {item}: {e}")
       raise


@step('I log in via Entra ID')
@step('I am logged in via EntraID')
@async_run_until_complete
async def step_pre_authenticated_login(context):
    if not hasattr(context, "browser"):
        context.browser = await context.playwright.chromium.launch(headless=False)

    base_dir = os.path.dirname(__file__)
    session_file = os.path.abspath(os.path.join(base_dir, "..", "mocking_services", "auth_state.json"))

    # ← Key change: pass storage_state when creating the context
    if os.path.exists(session_file):
        context.context = await context.browser.new_context(storage_state=session_file)
        logging.info("💾 Loaded auth state into browser context")
    else:
        context.context = await context.browser.new_context()
        logging.warning("⚠️ No auth state found, starting fresh")

    context.page = await context.context.new_page()

    base_url = getattr(context, "base_url", None)
    login_page = LoginPage(context.page, base_url)
    await login_page.pre_auth_session(session_file)

    context.login_page = login_page
    
    
@step('the "{button_text}" button is disabled')
@async_run_until_complete
async def step_impl(context, button_text):
    # Use the Playwright page from the environment
    page = context.page

    # Use the locator strategy consistent with your click_element method
    locator = page.get_by_role("button", name=button_text)

    # Fallback for styled <a> buttons (like primary_button)
    if await locator.count() == 0:
        locator = page.locator(f"a.btn.btn-primary:has-text('{button_text}')")

    # Wait until the element is visible
    await locator.wait_for(state="visible", timeout=getattr(context, "element_timeout", 5000))

    # Assert that the button is disabled
    await expect(locator).to_be_disabled()


@step('a confirmation dialog should appear')
@async_run_until_complete
async def step_confirmation_dialog_appears(context):
    """Verify that a confirmation dialog appears with the expected content."""
    try:
        # Wait for the dialog element to be visible
        dialog = context.page.locator("dialog[aria-modal='true']")
        await dialog.wait_for(state="visible", timeout=10000)
        logging.info("✅ Confirmation dialog is visible")
        
        # Verify the heading contains the expected text
        heading = dialog.locator("h1, h2, h3, h4, h5, h6")
        await heading.first.wait_for(state="visible", timeout=5000)
        heading_text = await heading.first.inner_text()
        logging.info(f"Dialog heading: {heading_text}")
        
        # # Verify it's a delete confirmation (or at least has a message)
        # if not heading_text:
        #     raise AssertionError("Dialog heading is empty")
        
        # # Verify Delete button is present
        # delete_button = dialog.locator("button:has-text('Delete')")
        # delete_count = await delete_button.count()
        # if delete_count == 0:
        #     raise AssertionError("No Delete button found in confirmation dialog")
        
        # logging.info("✅ Confirmation dialog appears with Delete button")
        
    except Exception as e:
        logging.error(f"❌ Confirmation dialog check failed: {e}")
        raise


@step('I click the "{button_text}" button on the dialog box')
@async_run_until_complete
async def step_click_button_on_dialog(context, button_text):
    """Click a button on the confirmation dialog."""
    try:
        # Find the dialog
        dialog = context.page.locator("dialog[aria-modal='true']")
        await dialog.wait_for(state="visible", timeout=10000)
        logging.info(f"Dialog is visible, looking for '{button_text}' button")
        
        # Find the button within the dialog
        button = dialog.locator(f"button:has-text('{button_text}')")
        button_count = await button.count()
        
        if button_count == 0:
            # Try alternative: data-testid approach
            button = dialog.locator(f"button[data-testid='button']:has-text('{button_text}')")
            button_count = await button.count()
        
        if button_count == 0:
            raise ValueError(f"No '{button_text}' button found on dialog")
        
        # Wait for button to be visible and click it
        await button.first.wait_for(state="visible", timeout=5000)
        await button.first.click()
        logging.info(f"✅ Clicked '{button_text}' button on dialog")
        
    except Exception as e:
        logging.error(f"❌ Failed to click '{button_text}' button on dialog: {e}")
        raise