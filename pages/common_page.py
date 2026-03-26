"""Common page object with shared methods for UI interactions."""
import asyncio 
from asyncio.log import logger
import logging

from pytest_playwright.pytest_playwright import context
from hamcrest import assert_that, has_item, equal_to, has_entries
from typing import Callable


class Common:
    def __init__(self, page, base_url=None, context=None, element_timeout: int = 10000):
        self.page = page
        self.context = context
        self.base_url = base_url
        self.element_timeout = element_timeout


    async def get_headings(self):
        """Return all visible heading texts (<h2> or .page-title)."""
        locator = self.page.locator("h2.page-title, h2, [class*='page-title'], h1, govuk-heading-l, h1.govuk-heading-l")
        await locator.first.wait_for(state="visible", timeout=self.element_timeout)

        count = await locator.count()
        headings = [(await locator.nth(i).inner_text()).strip() for i in range(count)]
        logging.info(f"✅ Found page headings: {headings}")
        return headings


    async def heading_is_displayed(self, expected_text: str) -> bool:
        """Check if the expected heading text is displayed (case-insensitive)."""
        headings = await self.get_headings()
        logging.info(f"Headings are: {headings}")
        return expected_text.lower() in [h.lower() for h in headings]


    async def click_element(self, item, retries=3, file_to_upload: str | None = None, select_option: str | None = None):
        """Click a UI element or upload a file based on its type."""
        await self.page.wait_for_load_state("networkidle")

        # --- Locator strategies ---
        locator_strategies: dict[str, Callable] = {
            "link":              lambda name: self.page.get_by_role("link").filter(has_text=name),
            "label":             lambda name: self.page.get_by_label(name),
            "button":            lambda name: self.page.get_by_role("button", name=name, exact=True),
            "primary_button":    lambda name: self.page.locator(f"a.btn.btn-primary:has-text('{name}')"),
            "file_input":        lambda _: self.page.locator("input[type='file'][name='fileUpload']"),
            "checkbox":          lambda _:    self.page.locator("input.govuk-checkboxes__input").first,
            "header_link":       lambda name: self.page.locator(f"a.govuk-header__link:has-text('{name}')"),
            "select_dropdown":   lambda name: self.page.locator(f"select[name='{name}']"),
            "subnav_button_first":  lambda _: self.page.get_by_role("button", name="Daily status update").first,
            "subnav_button_local":  lambda _: self.page.get_by_test_id("left-navigation").locator("div").filter(has_text="Local/regional area").get_by_role("button"),
            "subnav_button_third":  lambda _: self.page.get_by_role("button", name="Daily status update").nth(2),
            "checkbox_label": lambda name: self.page.locator(f"label.govuk-checkboxes__label:has-text('{name}')").first,
            "govuk_checkbox_first": lambda _: self.page.locator(
                'input[id^="checkbox-"].govuk-checkboxes__input[type="checkbox"]'
            ).first,
            "modal_button": lambda name: self.page.get_by_test_id("modal").get_by_test_id("button"),

            "test_id_link": lambda name: (
                                        lambda base, idx: base.first if idx is None else base.nth(idx)
                                        )   (
                                        self.page.get_by_role("link", name=name.split(" [")[0]),
                                        int(name.split("[link:")[1].rstrip("]")) if "[link:" in name else None
                                        ),
            "warning_button": lambda name: self.page.get_by_test_id("button").filter(has_text=name.split(" [")[0]),
        }

        # --- Item categories (to choose strategy) ---
        link_items:         set[str] = {"Search CDR", "Upload", "Failed AMR", "Failed CDR", "Create CDR record",
                                         "Quality control", "Alerts", "Notifications", "Authorisations", "Translations"}
        label_items:        set[str] = {"Search for a record ID"}
        file_input_items:   set[str] = {"Choose File", "File Upload", "No file chosen"}
        checkbox_items:     set[str] = {"checkbox"}
        header_link_items:  set[str] = {"Configuration"}
        dropdown_items:     set[str] = {"filterBy", "Select a laboratory", #standard dropdowns
                                        "ethnicity", "sex", "testMethod", "specimenType", "reportingLaboratory", "organism", "country", "antimicrobial", "sensitivityResult", "feature", "travelAbroadIndicator", "outbreakIndicator", "vaccinationStatus", "patientDeathIndicator", "hospitalAcquiredIndicator", "immuno-compromisedIndicator", "asymptomaticIndicator", "bacteraemiaSource", #create CDR dropdowns
                                        "systemCodeDescription", "gp"} #translation dropdowns
        checkbox_label_items: set[str] = {"Adrenal", "Abiotrophia", "Absidia", "Aspiration", "abiotrophia", "adrenal", "absidia", "aspiration", "abdominal pain", "acute arthritis"}
        test_id_link_items: dict[str, str] = {
                                            "Edit":            "test_id_link",
                                            "Delete [link]":   "test_id_link",   # defaults to .first
                                            "Delete [link:1]": "test_id_link",   # .nth(1)
                                            "Delete [link:2]": "test_id_link",   # .nth(2)
                                            "Delete [link:3]": "test_id_link",   # .nth(3) ... and so on
                                            }
        warning_button_items: set[str] = {"Delete [button]", "Delete [errors]"}
        govuk_checkbox_items: set[str] = {"govuk_checkbox_first"}
        subnav_button_items: dict[str, str] = {
            "Daily status update [first]": "subnav_button_first",
            "Daily status update [local]": "subnav_button_local",
            "Daily status update [third]": "subnav_button_third",
            }

        # --- Determine strategy ---
        if item in link_items:
            strategy_key = "link"
            item_locator = locator_strategies[strategy_key](item)
        elif item in label_items:
            strategy_key = "label"
            item_locator = locator_strategies[strategy_key](item)
        elif item in file_input_items:
            strategy_key = "file_input"
            item_locator = locator_strategies[strategy_key](item)
        elif item in checkbox_items:
            strategy_key = "checkbox"
            item_locator = locator_strategies[strategy_key](item)
        elif item in header_link_items:
            strategy_key = "header_link"
            item_locator = locator_strategies[strategy_key](item)
        elif item in dropdown_items:
            strategy_key = "select_dropdown"
            item_locator = locator_strategies[strategy_key](item)
        elif item in test_id_link_items:
            strategy_key = "test_id_link"
            item_locator = locator_strategies[strategy_key](item)
        elif item in checkbox_label_items:
            strategy_key = "checkbox_label"
            item_locator = locator_strategies[strategy_key](item)
        elif item in warning_button_items:
            strategy_key = "modal_button" if item == "Delete [errors]" else "warning_button"
            item_locator = locator_strategies[strategy_key](item)
        elif item in subnav_button_items:
            strategy_key = subnav_button_items[item]
            item_locator = locator_strategies[strategy_key](item)
        elif await self.page.locator(f"label.govuk-checkboxes__label:has-text('{item}')").count() > 0:
            strategy_key = "checkbox_label"
            item_locator = locator_strategies[strategy_key](item)
        else:
            strategy_key = "button"
            item_locator = locator_strategies[strategy_key](item)

        # Fallback for styled <a> buttons — checked once, before the retry loop
        if strategy_key == "button" and await item_locator.count() == 0:
            logging.debug(f"No role='button' found for '{item}', trying .btn.btn-primary fallback.")
            item_locator = locator_strategies["primary_button"](item)

        # --- Retry logic ---
        element_timeout = getattr(self, "element_timeout", 5000)

        for attempt in range(retries):
            try:
                await item_locator.wait_for(state="visible", timeout=element_timeout)

                if strategy_key == "file_input":
                    if not file_to_upload:
                        raise ValueError(f"No file provided for upload element '{item}'.")
                    await item_locator.evaluate("el => el.removeAttribute('hidden')")
                    await item_locator.evaluate("el => el.style.display = 'block'")
                    await item_locator.set_input_files(file_to_upload)
                    logging.info(f"📁 Uploaded file '{file_to_upload}' successfully via '{item}'.")
                elif strategy_key == "select_dropdown":
                    if not select_option:
                        raise ValueError(f"No option provided for dropdown '{item}'. Pass select_option='...'.")
                    await item_locator.select_option(label=select_option)
                    logging.info(f"🔽 Selected '{select_option}' from dropdown '{item}' on attempt {attempt + 1}")
                else:
                    await item_locator.click(timeout=element_timeout)
                    logging.info(f"✅ Clicked '{item}' on attempt {attempt + 1}")

                return

            except Exception as ex:
                logging.warning(f"⚠️ Attempt {attempt + 1}/{retries} failed for '{item}': {ex}")
                if attempt < retries - 1:
                    await asyncio.sleep(1)
                else:
                    logging.error(f"❌ All {retries} attempts failed for '{item}'")
                    raise

    @staticmethod
    async def get_table_data_from_tab(page, tab_name: str, exclude_columns: list = None):
        """Extract table data from a specific tab.
        
        Args:
            page: Playwright page object
            tab_name: Name of the tab (e.g., "Failed Validation")
            exclude_columns: List of column headers to exclude from results (e.g., ["Select"])
        
        Returns:
            List of dictionaries where each dict represents a row with column names as keys
        
        Example:
            data = await Common.get_table_data_from_tab(page, "Failed Validation", exclude_columns=["Select"])
        """
        exclude_columns = exclude_columns or []
        
        try:
            # Find the tab by role='tab' and matching text
            tab_selector = f"a[role='tab']:has-text('{tab_name}')"
            tab = page.locator(tab_selector)
            
            # Wait for tab to be visible
            await tab.wait_for(state="visible", timeout=15000)
            logging.info(f"📑 Tab '{tab_name}' is visible")
            
            # Click the tab to ensure it's active
            await tab.click()
            logging.info(f"✅ Clicked tab: '{tab_name}'")
            
            # Get the panel ID from aria-controls
            panel_id = await tab.get_attribute("aria-controls")
            if not panel_id:
                raise ValueError(f"Tab '{tab_name}' has no aria-controls attribute")
            
            # Wait for the panel to be visible
            panel = page.locator(f"#{panel_id}")
            await panel.wait_for(state="visible", timeout=15000)
            logging.info(f"Panel #{panel_id} is visible")
            
            # Wait for network to settle
            try:
                await page.wait_for_load_state("networkidle", timeout=15000)
            except Exception as e:
                logging.debug(f"Network idle timeout: {e}")
            
            # Add delay to ensure rendering
            await asyncio.sleep(1)
            
            # Find the table in the panel
            table = panel.locator("table")
            table_count = await table.count()
            
            if table_count == 0:
                raise ValueError(f"No table found in '{tab_name}' tab")
            
            logging.debug(f"Found {table_count} table(s) in '{tab_name}' tab")
            
            # Extract table headers
            header_cells = table.locator("thead tr th, thead tr td")
            header_count = await header_cells.count()
            headers = []
            
            for i in range(header_count):
                header_text = (await header_cells.nth(i).inner_text()).strip()
                headers.append(header_text)
            
            logging.debug(f"Table headers: {headers}")
            
            # Extract table rows
            rows = table.locator("tbody tr")
            row_count = await rows.count()
            
            if row_count == 0:
                logging.info(f"No rows found in '{tab_name}' tab table")
                return []
            
            logging.debug(f"Found {row_count} rows in '{tab_name}' tab table")
            
            table_data = []
            for row_idx in range(row_count):
                row = rows.nth(row_idx)
                cells = row.locator("td")
                cell_count = await cells.count()
                
                row_dict = {}
                for col_idx in range(cell_count):
                    if col_idx < len(headers):
                        header = headers[col_idx]
                        
                        # Skip excluded columns
                        if header in exclude_columns:
                            continue
                        
                        cell_text = (await cells.nth(col_idx).inner_text()).strip()
                        row_dict[header] = cell_text
                
                table_data.append(row_dict)
            
            logging.info(f"✅ Extracted {len(table_data)} rows from '{tab_name}' tab table")
            return table_data
            
        except Exception as e:
            logging.error(f"❌ Failed to extract table data from '{tab_name}' tab: {e}")
            raise

    @staticmethod
    async def verify_govuk_table_has_records(page, timeout: int = 15000):
        """Verify that a govuk-table has loaded with records.
        
        Args:
            page: Playwright page object
            timeout: Maximum time to wait for rows in milliseconds
        
        Returns:
            int: Number of rows found
        
        Raises:
            ValueError: If no table is found
            AssertionError: If table has no rows
        
        Example:
            row_count = await Common.verify_govuk_table_has_records(page)
        """
        try:
            # Locate the govuk-table, falling back to any table
            table = page.locator("table.govuk-table")
            table_count = await table.count()

            if table_count == 0:
                logging.warning("No govuk-table found, falling back to any table")
                table = page.locator("table")
                table_count = await table.count()

            if table_count == 0:
                raise ValueError("No table found on page")

            logging.info(f"✅ Found govuk-table")

            # Wait for network to settle before checking rows
            try:
                await page.wait_for_load_state("networkidle", timeout=timeout)
            except Exception as e:
                logging.debug(f"Network idle timeout (continuing): {e}")

            # Poll for tbody rows across up to 3 attempts
            tbody_rows = table.locator("tbody tr")
            row_count = 0

            for attempt in range(3):
                row_count = await tbody_rows.count()
                logging.debug(f"Attempt {attempt + 1}: Found {row_count} rows")
                if row_count > 0:
                    break
                await asyncio.sleep(1)

            if row_count == 0:
                raise AssertionError("govuk-table has no rows - records have not loaded")

            # Confirm the first row is actually visible
            await tbody_rows.first.wait_for(state="visible", timeout=timeout)

            logging.info(f"✅ govuk-table loaded with {row_count} record(s)")
            return row_count

        except Exception as e:
            logging.error(f"❌ govuk-table records check failed: {e}")
            raise
    
    @staticmethod
    async def verify_record_removed_from_govuk_table(page, panel, record_id: str, tab_name: str, timeout: int = 10000):
        """Verify a record has been removed from a govuk-table.

        Args:
            page: Playwright page object
            panel: Playwright locator for the active tab panel
            record_id: The ID of the deleted record to check for
            tab_name: Name of the tab (used for logging only)
            timeout: Maximum time to wait for network idle in milliseconds

        Raises:
            AssertionError: If the record is still found in the table

        Example:
            await Common.verify_record_removed_from_govuk_table(page, panel, "REC-123", "Failed Validation")
        """
        try:
            # Wait for network to settle after deletion
            try:
                await page.wait_for_load_state("networkidle", timeout=timeout)
            except Exception as e:
                logging.debug(f"Network idle timeout (continuing): {e}")

            # Small delay for govuk-table to re-render
            await asyncio.sleep(1)

            # Locate the govuk-table, falling back to any table
            table = panel.locator("table.govuk-table")
            if await table.count() == 0:
                logging.warning("No govuk-table found, falling back to any table")
                table = panel.locator("table")

            # Check 1: checkbox with the record ID is gone
            record_checkbox = table.locator(f"input[id='checkbox-{record_id}']")
            if await record_checkbox.count() > 0:
                raise AssertionError(
                    f"Record '{record_id}' still exists in '{tab_name}' tab (checkbox found) - deletion failed"
                )

            # Check 2: record ID no longer appears in any tbody row
            record_row = table.locator(f"tbody tr:has-text('{record_id}')")
            if await record_row.count() > 0:
                raise AssertionError(
                    f"Record '{record_id}' still visible in '{tab_name}' tab (row text found) - deletion failed"
                )

            logging.info(f"✅ Record '{record_id}' successfully removed from '{tab_name}' tab")

        except Exception as e:
            logging.error(f"❌ Record removal verification failed in '{tab_name}' tab: {e}")
            raise

    def format_filter_value(val: str) -> str:
        """Return val unquoted if numeric, quoted if string."""
        try:
            float(val)
            return val
        except ValueError:
            return f"'{val}'"
