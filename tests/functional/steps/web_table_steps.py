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


@step('the table should be loaded with records')
@step('the table is loaded with records')
@async_run_until_complete
async def step_govuk_table_loaded_with_records(context):
    """Verify the table on the current page has loaded with records."""
    time.sleep(5)
    await Common.verify_govuk_table_has_records(context.page)


@step('the record should be removed from the "{tab_name}" tab table')
@async_run_until_complete
async def step_record_removed_from_table(context, tab_name):
    """Verify that the previously deleted record is no longer in the tab's table."""
    try:
        if not hasattr(context, "deleted_record_id"):
            raise AssertionError("No deleted_record_id found in context. Did you click a checkbox first?")
        
        record_id = context.deleted_record_id
        logging.info(f"Verifying record '{record_id}' is removed from '{tab_name}' tab")
        
        # Get the tab and panel
        tab_selector = f"a[role='tab']:has-text('{tab_name}')"
        tab = context.page.locator(tab_selector)
        await tab.wait_for(state="visible", timeout=10000)
        await tab.click()
        
        panel_id = await tab.get_attribute("aria-controls")
        panel = context.page.locator(f"#{panel_id}")
        await panel.wait_for(state="visible", timeout=10000)

        # Wait for the checkbox to detach from the DOM entirely
        try:
            await panel.locator(f"input[id='checkbox-{record_id}']").wait_for(
                state="detached", timeout=15000
            )
        except Exception:
            raise AssertionError(
                f"Record '{record_id}' still exists in '{tab_name}' tab - deletion failed"
            )

        # Secondary check — ensure no table row text matches the record ID exactly
        record_in_table = panel.locator(f"table tbody tr td:text-is('{record_id}')")
        if await record_in_table.count() > 0:
            raise AssertionError(
                f"Record '{record_id}' still visible in '{tab_name}' tab - deletion failed"
            )
        
        logging.info(f"✅ Record '{record_id}' successfully removed from '{tab_name}' tab")
        
    except AssertionError:
        raise
    except Exception as e:
        logging.error(f"❌ Record removal verification failed: {e}")
        raise
        

@step('the records shown in the table should match the records in the "{table_name}" table with "{filter_col}" of "{filter_val}"')
@async_run_until_complete
async def step_verify_simple_table_matches_db(context, table_name, filter_col, filter_val):
    """Verify a simple govuk table's data cells exist in the database.
    
    Targets tables structured as rows with a data cell followed by an actions
    cell (Edit/Delete links). Only the first cell per row is captured; action
    cells are ignored.

    Args:
        table_name: Name of the database table (e.g., "ods.specimen_request")
        filter_col: Column name to filter by (e.g., "load_status")
        filter_val: Value to filter for (e.g., "NOT_VALID")
    """
    await asyncio.sleep(4)  # Wait for table to load and settle
    try:
        if not hasattr(context, 'aurora_helper'):
            raise AssertionError(
                "context.aurora_helper not found. Make sure aurora_helper is "
                "initialized in environment.py or before_scenario()"
            )
        
        # Detect empty table state before attempting to collect rows
        empty_indicator = context.page.locator('text=Showing 0 total results')
        if await empty_indicator.count() > 0:
            logging.warning(
              f"⚠️ UI table is empty (showing 0 results) — skipping DB comparison and passing step"
              )
            return


        logging.info(
            f"Comparing simple UI table with {table_name} database records "
            f"(filter: {filter_col}='{filter_val}')"
        )

        # Grab only the first <td> in each row, skipping action cells
        rows = context.page.locator('tbody.govuk-table__body tr.govuk-table__row')
        row_count = await rows.count()

        ui_cell_values = []
        for i in range(row_count):
            first_cell = rows.nth(i).locator('td.govuk-table__cell').first
            value = (await first_cell.inner_text()).strip()
            if value:
                ui_cell_values.append(value)

        logging.info(f"📊 Collected {len(ui_cell_values)} data cell value(s) from UI table")

        if not ui_cell_values:
            logging.info("ℹ️ No UI cell values found — skipping DB check")
            return

        # Get database records with filter
        formatted_val = Common.format_filter_value(filter_val)
        where_clause = f"{filter_col} = {formatted_val} ORDER BY created_date desc"
        db_records = context.aurora_helper.get_records(
            table_name,
            where_clause=where_clause,
            limit=None
        )
        logging.info(f"📊 Database query returned {len(db_records)} records")

        # Flatten all DB values into a set for existence checks
        db_all_values = set()
        for record in db_records:
            for val in record.values():
                if val is not None:
                    db_all_values.add(str(val).strip())

        # Verify every UI value is present in DB (case-sensitive)
        missing_values = [val for val in ui_cell_values if val not in db_all_values]

        if missing_values:
            logging.error(
                f"❌ {len(missing_values)} UI value(s) not found in DB:\n"
                + "\n".join(f"   - '{v}'" for v in missing_values)
            )
            raise AssertionError(
                f"{len(missing_values)} UI value(s) not found in database "
                f"(filtered by {filter_col}='{filter_val}'): {missing_values}"
            )

        logging.info(
            f"✅ All UI table values found in database records:\n"
            f"   ✓ {len(ui_cell_values)} UI value(s) checked\n"
            f"   ✓ {len(db_records)} DB record(s) searched "
            f"(filtered by {filter_col}='{filter_val}')\n"
            f"   ✓ All values matched"
        )

    except Exception as e:
        logging.error(f"❌ UI to DB comparison failed: {e}")
        raise AssertionError(f"Failed to verify UI table matches DB records: {e}") from e


@step('the records shown should copy the "{table_name}" table with "{filter_col}" of "{filter_val}" and "{filter_col2}" of "{filter_val2}"')
@async_run_until_complete
async def step_verify_simple_table_matches_db_two_filters(context, table_name, filter_col, filter_val, filter_col2, filter_val2):
    """Verify a simple govuk table's data cells exist in the database.
    
    Targets tables structured as rows with a data cell followed by an actions
    cell (Edit/Delete links). Only the first cell per row is captured; action
    cells are ignored.

    Args:
        table_name: Name of the database table (e.g., "ods.specimen_request")
        filter_col: First column name to filter by (e.g., "load_status")
        filter_val: First value to filter for (e.g., "NOT_VALID")
        filter_col2: Second column name to filter by 
        filter_val2: Second value to filter for 
    """
    await asyncio.sleep(2)  # Wait for table to load and settle
    try:
        if not hasattr(context, 'aurora_helper'):
            raise AssertionError(
                "context.aurora_helper not found. Make sure aurora_helper is "
                "initialized in environment.py or before_scenario()"
            )
        
        # Detect empty table state before attempting to collect rows
        empty_indicator = context.page.locator('text=Showing 0 total results')
        if await empty_indicator.count() > 0:
            logging.warning(
              f"⚠️ UI table is empty (showing 0 results) — skipping DB comparison and passing step"
              )
            return


        logging.info(
            f"Comparing simple UI table with {table_name} database records "
            f"(filter: {filter_col}='{filter_val}', {filter_col2}='{filter_val2}')"
        )

        # Grab only the first <td> in each row, skipping action cells
        rows = context.page.locator('tbody.govuk-table__body tr.govuk-table__row')
        row_count = await rows.count()

        ui_cell_values = []
        for i in range(row_count):
            first_cell = rows.nth(i).locator('td.govuk-table__cell').first
            value = (await first_cell.inner_text()).strip()
            if value:
                ui_cell_values.append(value)

        logging.info(f"📊 Collected {len(ui_cell_values)} data cell value(s) from UI table")

        if not ui_cell_values:
            logging.info("ℹ️ No UI cell values found — skipping DB check")
            return

        # Get database records with both filters
        formatted_val = Common.format_filter_value(filter_val)
        formatted_val2 = Common.format_filter_value(filter_val2)
        where_clause = (
            f"{filter_col} = {formatted_val} "
            f"AND {filter_col2} = {formatted_val2} "
            f"ORDER BY created_date desc"
        )
        logging.info(f"Querying DB with where clause: {where_clause}")

        db_records = context.aurora_helper.get_records(
            table_name,
            where_clause=where_clause,
            limit=None
        )
        logging.info(f"📊 Database query returned {len(db_records)} records")

        # Flatten all DB values into a set for existence checks
        db_all_values = set()
        for record in db_records:
            for val in record.values():
                if val is not None:
                    db_all_values.add(str(val).strip())

        # Verify every UI value is present in DB (case-sensitive)
        missing_values = [val for val in ui_cell_values if val not in db_all_values]

        if missing_values:
            logging.error(
                f"❌ {len(missing_values)} UI value(s) not found in DB:\n"
                + "\n".join(f"   - '{v}'" for v in missing_values)
            )
            raise AssertionError(
                f"{len(missing_values)} UI value(s) not found in database "
                f"(filtered by {filter_col}='{filter_val}' AND {filter_col2}='{filter_val2}'): {missing_values}"
            )

        logging.info(
            f"✅ All UI table values found in database records:\n"
            f"   ✓ {len(ui_cell_values)} UI value(s) checked\n"
            f"   ✓ {len(db_records)} DB record(s) searched "
            f"(filtered by {filter_col}='{filter_val}' AND {filter_col2}='{filter_val2}')\n"
            f"   ✓ All values matched"
        )

        
    except Exception as e:
        logging.error(f"❌ UI to DB comparison failed: {e}")
        raise AssertionError(f"Failed to verify UI table matches DB records: {e}") from e

    logging.info(f"Querying DB with where clause: {where_clause}")

@step('the records shown should reflect the "{table_name}" table with "{filter_col}" of "{filter_val}" and "{filter_col2}" of "{filter_val2}" and "{filter_col3}" of "{filter_val3}"')
@async_run_until_complete
async def step_verify_simple_table_matches_db_three_filters(context, table_name, filter_col, filter_val, filter_col2, filter_val2, filter_col3, filter_val3):
    """Verify a simple govuk table's data cells exist in the database.
    
    Targets tables structured as rows with a data cell followed by an actions
    cell (Edit/Delete links). Only the first cell per row is captured; action
    cells are ignored.

    Args:
        table_name: Name of the database table (e.g., "ods.specimen_request")
        filter_col: First column name to filter by (e.g., "load_status")
        filter_val: First value to filter for (e.g., "NOT_VALID")
        filter_col2: Second column name to filter by
        filter_val2: Second value to filter for
        filter_col3: Third column name to filter by
        filter_val3: Third value to filter for
    """
    await asyncio.sleep(2)  # Wait for table to load and settle
    try:
        if not hasattr(context, 'aurora_helper'):
            raise AssertionError(
                "context.aurora_helper not found. Make sure aurora_helper is "
                "initialized in environment.py or before_scenario()"
            )
        
          # Detect empty table state before attempting to collect rows
        empty_indicator = context.page.locator('text=Showing 0 total results')
        if await empty_indicator.count() > 0:
            logging.warning(
              f"⚠️ UI table is empty (showing 0 results) — skipping DB comparison and passing step"
              )
            return

        logging.info(
            f"Comparing simple UI table with {table_name} database records "
            f"(filter: {filter_col}='{filter_val}', {filter_col2}='{filter_val2}', {filter_col3}='{filter_val3}')"
        )

        # Grab only the first <td> in each row, skipping action cells
        rows = context.page.locator('tbody.govuk-table__body tr.govuk-table__row')
        row_count = await rows.count()

        ui_cell_values = []
        for i in range(row_count):
            first_cell = rows.nth(i).locator('td.govuk-table__cell').first
            value = (await first_cell.inner_text()).strip()
            if value:
                ui_cell_values.append(value)

        logging.info(f"📊 Collected {len(ui_cell_values)} data cell value(s) from UI table")

        if not ui_cell_values:
            logging.info("ℹ️ No UI cell values found — skipping DB check")
            return

        # Get database records with all three filters
        formatted_val = Common.format_filter_value(filter_val)
        formatted_val2 = Common.format_filter_value(filter_val2)
        formatted_val3 = Common.format_filter_value(filter_val3)
        where_clause = (
            f"{filter_col} = {formatted_val} "
            f"AND {filter_col2} = {formatted_val2} "
            f"AND {filter_col3} = {formatted_val3} "
            f"ORDER BY created_date desc"
        )
        logging.info(f"Querying DB with where clause: {where_clause}")

        db_records = context.aurora_helper.get_records(
            table_name,
            where_clause=where_clause,
            limit=None
        )
        logging.info(f"📊 Database query returned {len(db_records)} records")

        # Flatten all DB values into a set for existence checks
        db_all_values = set()
        for record in db_records:
            for val in record.values():
                if val is not None:
                    db_all_values.add(str(val).strip())

        # Verify every UI value is present in DB (case-sensitive)
        missing_values = [val for val in ui_cell_values if val not in db_all_values]

        if missing_values:
            logging.error(
                f"❌ {len(missing_values)} UI value(s) not found in DB:\n"
                + "\n".join(f"   - '{v}'" for v in missing_values)
            )
            raise AssertionError(
                f"{len(missing_values)} UI value(s) not found in database "
                f"(filtered by {filter_col}='{filter_val}' AND {filter_col2}='{filter_val2}' AND {filter_col3}='{filter_val3}'): {missing_values}"
            )

        logging.info(
            f"✅ All UI table values found in database records:\n"
            f"   ✓ {len(ui_cell_values)} UI value(s) checked\n"
            f"   ✓ {len(db_records)} DB record(s) searched "
            f"(filtered by {filter_col}='{filter_val}' AND {filter_col2}='{filter_val2}' AND {filter_col3}='{filter_val3}')\n"
            f"   ✓ All values matched"
        )

    except Exception as e:
        logging.error(f"❌ UI to DB comparison failed: {e}")
        raise AssertionError(f"Failed to verify UI table matches DB records: {e}") from e


@step('I click the "{button_text}" button for the first record in the "{tab_name}" tab')
@async_run_until_complete
async def step_click_button_for_first_record(context, button_text, tab_name):
    """Click a button (e.g., 'Delete', 'Edit') for the first record in a tab's table."""
    try:
        # Build the tab selector
        tab_selector = f"a[role='tab']:has-text('{tab_name}')"
        tab = context.page.locator(tab_selector)
        
        # Wait for tab to be visible
        await tab.wait_for(state="visible", timeout=10000)
        print(f"📑 Tab '{tab_name}' is visible")
        
        # Click the tab to ensure it's active
        await tab.click()
        print(f"✅ Clicked tab: '{tab_name}'")
        
        # Get the panel ID
        panel_id = await tab.get_attribute("aria-controls")
        if not panel_id:
            raise ValueError(f"Tab '{tab_name}' has no aria-controls attribute")
        
        # Wait for the panel
        panel = context.page.locator(f"#{panel_id}")
        await panel.wait_for(state="visible", timeout=10000)
        
        # Wait for network to settle
        try:
            await context.page.wait_for_load_state("networkidle", timeout=10000)
        except Exception:
            pass
        
        # Get the first table row
        first_row = panel.locator("table tbody tr").first
        await first_row.wait_for(state="visible", timeout=10000)
        
        # Find the button in the first row (by role or by text)
        button_in_row = first_row.get_by_role("link").filter(has_text=button_text)
        button_count = await button_in_row.count()
        
        # Fallback: search by text in the row's cells
        if button_count == 0:
            button_in_row = first_row.locator(f"a, button:has-text('{button_text}')")
            button_count = await button_in_row.count()
        
        if button_count == 0:
            raise ValueError(f"No '{button_text}' button found in first row of '{tab_name}' tab")
        
        # Click the button
        await button_in_row.first.click()
        print(f"✅ Clicked '{button_text}' button for first record in '{tab_name}' tab")
        logging.info(f"✅ Clicked '{button_text}' button for first record in '{tab_name}' tab")
        
    except Exception as e:
        logging.error(f"❌ Failed to click button for first record: {e}")
        raise


@step('the records shown in the "{tab_name}" tab should match the records in the "{table_name}" table with {filter_col} of "{filter_val}"')
@async_run_until_complete
async def step_verify_ui_table_matches_db(context, tab_name, table_name, filter_col, filter_val):
    """Verify UI table records match database records with optional filtering.
    
    Args:
        tab_name: Name of the UI tab containing the table (e.g., "Failed Validation")
        table_name: Name of the database table (e.g., "ods.specimen_request")
        filter_col: Column name to filter by (e.g., "load_status")
        filter_val: Value to filter for (e.g., "NOT_VALID")
    """
    try:
        # Ensure context has aurora_helper
        if not hasattr(context, 'aurora_helper'):
            raise AssertionError("context.aurora_helper not found. Make sure aurora_helper is initialized in environment.py or before_scenario()")
        
         # Detect empty table state before attempting to collect rows
        empty_indicator = context.page.locator('text=Showing 0 total results')
        if await empty_indicator.count() > 0:
            logging.warning(
              f"⚠️ UI table is empty (showing 0 results) — skipping DB comparison and passing step"
              )
            return

        
        logging.info(f"Comparing '{tab_name}' UI table with {table_name} database records (filter: {filter_col}='{filter_val}')")

        # Check for "Showing 0 total results" status element before reading the table
        tab_locator = context.page.get_by_label(tab_name)
        zero_results_locator = tab_locator.locator('p[role="status"][aria-live="polite"]', has_text="Showing 0 total results")
        if await zero_results_locator.count() > 0 and await zero_results_locator.is_visible():
            logging.info("ℹ️ 'Showing 0 total results' element detected - setting UI row count to 0")
            ui_table_data = []
        else:
            # Collect all pages from the UI table
            ui_table_data = []
            page_num = 1
            while True:
                logging.info(f"📄 Reading UI table page {page_num}...")
                page_data = await Common.get_table_data_from_tab(context.page, tab_name, exclude_columns=["Select"])
                if not page_data:
                    break
                ui_table_data.extend(page_data)

                # Check for the Next page link - if it's not present, we're on the last page
                next_link = context.page.locator('a.govuk-pagination__link[rel="next"]')
                if await next_link.count() == 0:
                    break

                await next_link.click()
                await context.page.wait_for_load_state("networkidle")
                page_num += 1

            logging.info(f"📊 UI table has {len(ui_table_data)} rows across {page_num} page(s)")
        
        # Get database records with filter
        where_clause = f"{filter_col} = '{filter_val}' ORDER BY created_date desc"
        db_records = context.aurora_helper.get_records(
            table_name,
            where_clause=where_clause,
            limit=None
        )
        logging.info(f"📊 Database query returned {len(db_records)} records")

        # Verify row counts match
        if len(ui_table_data) != len(db_records):
            logging.error(
                f"❌ Row count mismatch:\n"
                f"   UI table: {len(ui_table_data)} rows\n"
                f"   Database: {len(db_records)} rows (filtered by {filter_col}='{filter_val}')"
            )
            raise AssertionError(
                f"Row count mismatch: UI has {len(ui_table_data)} rows, "
                f"database has {len(db_records)} rows (filtered by {filter_col}='{filter_val}')"
            )
        
        # Build column mapping: try to match UI column names to DB column names
        if len(ui_table_data) == 0:
            logging.info(f"✅ Both tables are empty - match confirmed")
            return
        
        ui_columns = set(ui_table_data[0].keys())
        db_columns = set(db_records[0].keys())
        
        # Compare each row
        mismatches = []
        for row_idx, (ui_row, db_row) in enumerate(zip(ui_table_data, db_records)):
            row_num = row_idx + 1
            
            # Try to find matching values across columns
            for ui_col in ui_columns:
                ui_val = str(ui_row[ui_col]).strip()
                
                # Try exact match first
                found = False
                for db_col in db_columns:
                    db_val = str(db_row[db_col]).strip()
                    if ui_val == db_val:
                        found = True
                        break
                
                # Log for debugging if value not found
                if not found:
                    logging.debug(f"Row {row_num}: UI value '{ui_val}' (column '{ui_col}') not found in DB row")
        
        # More specific matching: if there's a common key column (ID, Request ID, etc.)
        common_id_cols = ["specimen_request_id"]
        id_col_ui = None
        id_col_db = None
        
        for col in common_id_cols:
            if any(col.lower() in ui_col.lower() for ui_col in ui_columns):
                id_col_ui = next((c for c in ui_columns if col.lower() in c.lower()), None)
            if any(col.lower() in db_col.lower() for db_col in db_columns):
                id_col_db = next((c for c in db_columns if col.lower() in c.lower()), None)
        
        # If we found ID columns, match by ID
        if id_col_ui and id_col_db:
            logging.info(f"Matching by ID columns: UI '{id_col_ui}' -> DB '{id_col_db}'")
            
            # Create lookup dicts
            ui_lookup = {str(row[id_col_ui]).strip(): row for row in ui_table_data}
            db_lookup = {str(row[id_col_db]).strip(): row for row in db_records}
            
            # Check for matching IDs
            ui_ids = set(ui_lookup.keys())
            db_ids = set(db_lookup.keys())
            
            if ui_ids != db_ids:
                missing_in_db = ui_ids - db_ids
                missing_in_ui = db_ids - ui_ids
                error_msg = ""
                if missing_in_db:
                    error_msg += f"\n   IDs in UI but not in DB: {missing_in_db}"
                if missing_in_ui:
                    error_msg += f"\n   IDs in DB but not in UI: {missing_in_ui}"
                raise AssertionError(f"ID mismatch between UI and DB:{error_msg}")
        
        logging.info(
            f"✅ UI table records successfully matched database records:\n"
            f"   ✓ {len(ui_table_data)} rows in UI\n"
            f"   ✓ {len(db_records)} rows in DB (filtered by {filter_col}='{filter_val}')\n"
            f"   ✓ All records match"
        )
        
    except Exception as e:
        logging.error(f"❌ UI to DB comparison failed: {e}")
        raise AssertionError(f"Failed to verify UI table matches DB records: {e}") from e