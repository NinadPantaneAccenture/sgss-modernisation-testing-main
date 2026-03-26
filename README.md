# SGSS Modernisation Test Automation Framework

A Python-based test automation framework using Behave (BDD) for end-to-end testing, with support for web UI testing, ETL testing, and performance testing.

## Project Structure

```
├── pages/                    # Page Object Model classes
│   ├── common_page.py       # Common page elements and actions
│   ├── landing_page.py      # Landing page interactions
│   ├── login_page.py        # Login page interactions
│   └── upload_page.py       # Upload page interactions
├── tests/
│   ├── e2e/                 # End-to-end tests
│   │   ├── features/        # Behave feature files (.feature)
│   │   ├── steps/           # Step definitions
│   │   ├── mocking_services/# Mock service generators
│   │   └── environment.py   # Behave environment setup
│   ├── performance/         # Performance tests
│   └── test_data/           # Test data files
├── reports/                 # Test execution reports
├── screenshots/             # Test failure screenshots
├── requirements.txt         # Python dependencies
├── behave.ini              # Behave configuration
└── README.md               # This file
```

## Prerequisites

- **Python 3.9+** (3.10+ recommended)
- **Git** (for version control)
- **VS Code** (latest version recommended)
- **Windows PowerShell 5.1+** or Command Prompt

## VS Code Environment Setup

### 1. Install Required VS Code Extensions

Install these extensions for optimal development and testing experience:

- **Python** (Microsoft) - `ms-python.python`
- **Pylance** (Microsoft) - `ms-python.vscode-pylance` (for Python language support)
- **Behave** - `marclark.behave` (for .feature file syntax highlighting)
- **Playwright Test for VSCode** (Microsoft) - `ms-playwright.playwright` (for Playwright testing)
- **Thunder Client** or **REST Client** (optional, for API testing)
- **Gherkin syntax highlighting** (optional) - `cucumberopen.gherkin-official`

**To install extensions:**
1. Open VS Code
2. Press `Ctrl+Shift+X` to open Extensions
3. Search for each extension by name and click "Install"

Alternatively, use the command palette (`Ctrl+Shift+P`) and type `Extensions: Install Extensions`.

### 2. Configure Python Interpreter

1. Open VS Code and navigate to this project folder
2. Press `Ctrl+Shift+P` and search for **"Python: Select Interpreter"**
3. Choose **"Create Virtual Environment"** or select an existing interpreter with Python 3.8+
4. Once selected, VS Code will display the Python version in the bottom-right corner

### 3. Create and Activate Virtual Environment

**Option A: Using VS Code's Built-in Terminal (Recommended)**

1. Open the integrated terminal: `Ctrl+`
2. Run the following command to create a virtual environment:
   ```powershell
   python -m venv venv
   ```
3. Activate the virtual environment:
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```
   - If you encounter a PowerShell execution policy error, run:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
     ```
4. You should see `(venv)` at the beginning of your terminal prompt

**Option B: Using Windows Command Prompt**

```cmd
python -m venv venv
venv\Scripts\activate.bat
```

### 4. Install Project Dependencies

With the virtual environment activated, install all required packages:

```powershell
pip install -r requirements.txt
```

Wait for the installation to complete. You should see `Successfully installed` messages.

### 5. Install Playwright Browsers

Behave tests use Playwright for browser automation. Install the required browsers:

```powershell
playwright install
```

This downloads Chromium, Firefox, and WebKit browsers needed for testing.

### 6. Configure VS Code Settings

Create or update `.vscode/settings.json` in your project root:

```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.testing.pytestEnabled": false,
  "python.testing.unittestEnabled": false,
  "[gherkin]": {
    "editor.defaultFormatter": "cucumberopen.gherkin-official",
    "editor.formatOnSave": true
  }
}
```

### 7. Configure Launch and Debug

Create `.vscode/launch.json` for debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Current File",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "justMyCode": true
    },
    {
      "name": "Behave: All Tests",
      "type": "python",
      "request": "launch",
      "module": "behave",
      "args": ["tests/e2e"],
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}"
    },
    {
      "name": "Behave: Specific Feature",
      "type": "python",
      "request": "launch",
      "module": "behave",
      "args": ["tests/e2e/features/web/CDR_WebUpload.feature"],
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

## Running Tests

### Via Terminal

1. Ensure your virtual environment is activated (you should see `(venv)` in the terminal)

2. **Run all tests:**
   ```powershell
   behave tests/e2e
   ```

3. **Run specific feature file:**
   ```powershell
   behave tests/e2e/features/web/CDR_WebUpload.feature
   ```

4. **Run tests with HTML report:**
   ```powershell
   behave tests/e2e -f json -o reports/test_results.json
   ```

5. **Run tests with specific tags:**
   ```powershell
   behave tests/e2e -t @smoke
   ```

### Via VS Code Debugger

1. Open `.vscode/launch.json` and select a configuration
2. Press `F5` or click the **Run and Debug** button on the left sidebar
3. Select the desired configuration (e.g., "Behave: All Tests")
4. Tests will run in the integrated terminal with debugging support

### View Test Reports

- **Plain text output:** See console output after test run
- **XML reports:** Located in `reports/` directory
- **Screenshots:** Failed tests capture screenshots in `screenshots/` directory

## Environment Configuration (WIP)

If environment-specific variables are needed, create a `.env` file in the project root:

```
WEB_BASE_URL=https://your-app-url.com
ETL_HOST=your-etl-host
ETL_PORT=5432
BROWSER=chromium
HEADLESS=true
```

Load these in your test files using `python-dotenv`:

```python
from dotenv import load_dotenv
import os

load_dotenv()
base_url = os.getenv('WEB_BASE_URL')
```

## Troubleshooting

### Issue: "Python interpreter not found"
- **Solution:** Go to `Ctrl+Shift+P` → "Python: Select Interpreter" and manually choose your Python installation or create a virtual environment.

### Issue: "behave command not found"
- **Solution:** Ensure virtual environment is activated (you should see `(venv)` in terminal) and run `pip install behave`.

### Issue: "Playwright browsers not installed"
- **Solution:** Run `playwright install` with the virtual environment activated.

### Issue: PowerShell execution policy error
- **Solution:** Run the following in PowerShell as Administrator:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Issue: VS Code not recognizing virtual environment
- **Solution:** 
  1. Close all VS Code terminals
  2. Reload VS Code window (`Ctrl+Shift+P` → "Developer: Reload Window")
  3. Open a new terminal

## Additional Resources

- [Behave Documentation](https://behave.readthedocs.io/)
- [Playwright Documentation](https://playwright.dev/python/)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [VS Code Python Extension Guide](https://code.visualstudio.com/docs/languages/python)

## Getting Help

For issues or questions:
1. Check the troubleshooting section above
2. Review test output and error messages carefully
3. Check project logs in the `reports/` and `screenshots/` directories
