"""Page Object for file upload functionality."""
import logging
import json

from pathlib import Path
from playwright.async_api import Page, Locator


class UploadPage:
    """Page Object for file upload functionality."""

    def __init__(self, page: Page):
        self.page = page
        self._file_map = None

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

    def message_locator(self, message: str) -> Locator:
        """Return a locator for a given message text."""
        return self.page.locator(f"text={message}").first
    

    async def wait_for_message(self, message: str, timeout: int = 5000) -> bool:
        """Wait until the message is visible on the page."""
        try:
            await self.message_locator(message).wait_for(state="visible", timeout=timeout)
            logging.info(f"✅ Message displayed: '{message}'")
            return True
        except Exception as e:
            logging.error(f"❌ Message not found: '{message}' - {e}")
            return False
