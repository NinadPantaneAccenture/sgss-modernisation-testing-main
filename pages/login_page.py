"""Page Object for login functionality and generating pre-authenticated sessions."""
import os
import json
import logging
from playwright.async_api import Page
from tests.functional.environment import BASE_URL    


class LoginPage:
    def __init__(self, page, base_url=None):   
        self.page = page
        self.base_url = base_url or BASE_URL  # Single default
    
    async def pre_auth_session(self, session_file_path: str):
        """
        Restores full browser auth state to bypass Entra ID popup.
        """
        if not os.path.exists(session_file_path):
            logging.warning(f"⚠️ {session_file_path} not found. Starting fresh session.")
            await self.page.goto(self.base_url, wait_until="networkidle")
            return

        logging.info(f"💾 Auth state found at {session_file_path}")
        await self.page.goto(self.base_url, wait_until="networkidle")
        logging.info("✅ Opened landing page with pre-authenticated session.")