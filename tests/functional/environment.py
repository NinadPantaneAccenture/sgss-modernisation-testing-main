"""Environment setup and teardown for end-to-end tests using Playwright."""
import asyncio
import random
import string
import re
from io import StringIO
import logging
import os
from pathlib import Path
from time import time
from dotenv import load_dotenv
from playwright.async_api import async_playwright
import zipfile


# Load environment variables from .env file
env_path = Path(__file__).parent.parent.parent / ".env"
load_dotenv(env_path)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BASE_URL = os.getenv("BASE_URL")

def resolve_value(context, value):
    match = re.match(r'^<RANDOM(\d+)?>$', value)
    if match:
        length = int(match.group(1)) if match.group(1) else 8
        return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))
    return value

def before_all(context):
    """Launch browser once for entire suite."""
    context.loop = asyncio.new_event_loop()
    asyncio.set_event_loop(context.loop)

     # Attach utilities
    context.resolve_value = lambda value: resolve_value(context, value)

    
    async def launch_browser():
        context.playwright = await async_playwright().start()
        
        # Get browser type from context config or default to chromium
        browser_name = context.config.userdata.get('browser', 'chromium').lower()
        
        # Map browser name to playwright browser type
        browser_map = {
            'chromium': context.playwright.chromium,
            'firefox': context.playwright.firefox,
            'webkit': context.playwright.webkit,
        }
        
        if browser_name not in browser_map:
            logging.warning(f"⚠️ Unknown browser '{browser_name}', defaulting to chromium")
            browser_name = 'chromium'
        
        browser_type = browser_map[browser_name]
        
        # Launch with headless option (also configurable)
        headless = context.config.userdata.get('headless', 'true').lower() == 'false'
        
        logging.info(f"🚀 Launching {browser_name} browser (headless={headless})")
        context.browser = await browser_type.launch(headless=headless)
    
    context.loop.run_until_complete(launch_browser())


def before_scenario(context, scenario):
    """Create fresh context and page for each scenario + start log capture."""

    # Logging setup
    context.log_stream = StringIO()
    context.log_capture = []

    log_handler = logging.StreamHandler(context.log_stream)
    log_handler.setLevel(logging.DEBUG)

    class BehaveHTMLHandler(logging.Handler):
        def emit(self, record):
            if record.levelno >= logging.WARNING:
                context.log_capture.append(self.format(record))

    html_handler = BehaveHTMLHandler()
    html_handler.setLevel(logging.WARNING)

    root_logger = logging.getLogger()
    root_logger.addHandler(log_handler)
    root_logger.addHandler(html_handler)

    context._log_handler = log_handler
    context._html_log_handler = html_handler

    # Existing browser setup
    async def setup():
        context.browser_context = await context.browser.new_context(
            viewport={'width': 1920, 'height': 1080}
        )
        context.page = await context.browser_context.new_page()

    context.loop.run_until_complete(setup())


def after_step(context, step):
    """Take a screenshot after every step + flush WARNING+ logs into HTML report."""
    # Flush captured log warnings into the HTML report
    if hasattr(context, 'log_capture') and context.log_capture:
        extra = "\n".join(context.log_capture)
        step.error_message = ((step.error_message or "") + "\n" + extra).strip()
        context.log_capture.clear()

    if not hasattr(context, 'page'):
        return

    timestamp = int(time())

    safe_step = "".join(c if c.isalnum() else "_" for c in step.name)[:60]
    safe_scenario = "".join(c if c.isalnum() else "_" for c in context.scenario.name)[:80]

    status = step.status.name

    screenshot_dir = Path("reports/screenshots") / safe_scenario
    screenshot_dir.mkdir(parents=True, exist_ok=True)

    filename = screenshot_dir / f"{timestamp}_{status}_{safe_step}.png"

    async def snap():
        await context.page.screenshot(path=str(filename), full_page=True)

    context.loop.run_until_complete(snap())
    logging.info(f"📸 Screenshot saved: {filename}")


def after_scenario(context, scenario):
    """Close context but keep browser running."""
    # Clean up both log handlers
    root_logger = logging.getLogger()
    if hasattr(context, '_log_handler'):
        root_logger.removeHandler(context._log_handler)
    if hasattr(context, '_html_log_handler'):
        root_logger.removeHandler(context._html_log_handler)

    async def teardown():
        if hasattr(context, 'page'):
            await context.page.close()
        await context.browser_context.close()

    context.loop.run_until_complete(teardown())


def after_all(context):
    """Close browser after all scenarios."""
    async def cleanup():
        if hasattr(context, 'browser'):
            await context.browser.close()
        if hasattr(context, 'playwright'):
            await context.playwright.stop()
    
    context.loop.run_until_complete(cleanup())
    context.loop.close()

    # Zip screenshots for easy attachment
    screenshot_dir = Path("reports/screenshots")
    if screenshot_dir.exists():
        zip_path = Path("reports/screenshots.zip")
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for img in screenshot_dir.rglob("*.png"):
                zf.write(img, img.relative_to(screenshot_dir))
        logging.info(f"📦 Screenshots zipped: {zip_path}")