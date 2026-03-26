import asyncio
import os

from dotenv import load_dotenv
from playwright.async_api import async_playwright

load_dotenv()
BASE_URL = os.getenv("BASE_URL")

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context()
        page = await context.new_page()

        await page.goto(f"{BASE_URL}", wait_until="domcontentloaded")
        print("🌐 Navigated to app")
        print("🔐 Please log in — enter your details and OTP when prompted")
        print("⏳ Waiting for you to reach the landing page...")

        # Block here until the URL changes to the landing page
        # Replace "/landing" with the actual path of your landing page
        await page.wait_for_url("**/records/upload**", timeout=300_000)

        await page.wait_for_load_state("networkidle")
        print("✅ Landing page reached!")

        script_dir = os.path.dirname(os.path.abspath(__file__))
        output_file = os.path.join(script_dir, "auth_state.json")
        await context.storage_state(path=output_file)
        print(f"💾 Saved auth state to {output_file}")

        await browser.close()

asyncio.run(main())