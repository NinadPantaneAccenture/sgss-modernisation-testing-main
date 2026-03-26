# Pre-GitHub Checklist

## Security Check ✅

Before pushing to GitHub, verify:

- [ ] `.env` file is **NOT** staged for commit
  ```bash
  git status  # Should NOT show .env
  ```

- [ ] No hardcoded AWS keys in any files
  ```bash
  git diff --cached | grep -i "AKIA"  # Should return nothing
  ```

- [ ] `.gitignore` includes `.env` and credentials
  ```bash
  grep ".env" .gitignore
  ```

- [ ] `.env.example` is committed (but `.env` is NOT)
  ```bash
  git status  # Should show: .env.example (staged), .env (ignored)
  ```

## Configuration Files ✅

Files to commit:
- ✅ `.env.example` - Safe template for environment variables
- ✅ `SECURITY.md` - Guidelines for credential management
- ✅ `CONTRIBUTING.md` - Setup instructions for collaborators
- ✅ `aws_services/aws_config.py` - Refactored to use environment variables

Files to NEVER commit:
- ❌ `.env` - Contains actual credentials
- ❌ `aws_services/aws_config_*.py` - Local configurations
- ❌ AWS credential JSON files

## Before First Push

1. Run security checks above
2. Test locally with `.env` file
3. Verify tests pass:
   ```bash
   behave
   ```
4. Clean up sensitive data:
   ```bash
   git log --oneline | head  # Review commit history
   ```

## If You Accidentally Committed Secrets

1. **Never delete and re-push** - Git history retains secrets
2. Immediately rotate AWS credentials in AWS console
3. Use BFG Repo-Cleaner or git-filter-branch to remove from history
4. Force push (only if repo hasn't been public yet)

## GitHub Repository Setup

Add to repo description:
```
⚠️ Before using: Copy .env.example to .env and add your AWS credentials
See CONTRIBUTING.md for setup instructions and SECURITY.md for credential guidelines
```

## Questions?

See [SECURITY.md](SECURITY.md) for detailed security guidelines.
