import os
import pytest

SCREENSHOT_DIR = "screenshots"

# Ensure screenshot directory exists
if not os.path.exists(SCREENSHOT_DIR):
    os.makedirs(SCREENSHOT_DIR)


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()

    if report.when == "call" and report.failed:
        page = item.funcargs.get("page")

        if page:
            screenshot_file = os.path.join(
                SCREENSHOT_DIR,
                f"{item.name}.png"
            )

            page.screenshot(path=screenshot_file)