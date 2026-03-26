# Contributing to SGSS Modernisation Test Automation Framework

## Local Development Setup

### Prerequisites

- Python 3.8+
- Git
- AWS account credentials (for testing against AWS services)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/SGSSModernisation_TestAutomationFramework.git
   cd SGSSModernisation_TestAutomationFramework
   ```

2. Create a virtual environment:
   ```bash
   python -m venv .venv
   ```

3. Activate the virtual environment:
   - **Windows (PowerShell):**
     ```powershell
     .\.venv\Scripts\Activate.ps1
     ```
   - **macOS/Linux:**
     ```bash
     source .venv/bin/activate
     ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Create your `.env` file:
   ```bash
   cp .env.example .env
   ```

6. Edit `.env` and add your configuration:
   ```bash
   # Add your AWS credentials, S3 bucket names, etc.
   # See SECURITY.md for credential management best practices
   ```

### Running Tests

```bash
# Run all Behave tests
behave

# Run specific feature file
behave tests/functional/features/e2e/e2e_FileUpload.feature

# Run with specific tags
behave -t @CDR -t @HappyPath

# Generate HTML report
behave -f html -o reports/report.html
```

### Environment Variables

See `.env.example` for all required environment variables. Ensure your `.env` file is never committed.

For detailed security guidelines, see [SECURITY.md](SECURITY.md).

## Code Style

- Follow PEP 8 style guidelines
- Use meaningful variable and function names
- Add docstrings to functions and classes
- Comment complex logic

## Git Workflow

1. Create a branch for your feature: `git checkout -b feature/my-feature`
2. Commit your changes: `git commit -am 'Add new feature'`
3. Push to the branch: `git push origin feature/my-feature`
4. Submit a pull request

## Before Pushing to GitHub

- ✅ Verify no `.env` file is staged: `git status`
- ✅ Ensure `.gitignore` includes `.env`
- ✅ Check for hardcoded credentials in your changes
- ✅ Run tests locally to ensure they pass

## Questions?

See [SECURITY.md](SECURITY.md) for security-related questions about credential management.
