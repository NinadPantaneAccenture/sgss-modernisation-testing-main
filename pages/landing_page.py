"""Page Object for the landing page."""
from playwright.async_api import Page
from tests.functional.environment import BASE_URL

class LandingPage:
    def __init__(self, page: Page, base_url: str = None):
        self.page = page
        self.base_url = base_url or BASE_URL
    
    async def go_to(self):
        """Navigate to the landing page and wait for it to load."""
        try:
            await self.page.goto(self.base_url, wait_until='domcontentloaded', timeout=60000)
            # Use domcontentloaded instead of networkidle to avoid timeout on CloudFront
        except Exception as e:
            raise RuntimeError(f"Failed to navigate to landing page: {e}")
