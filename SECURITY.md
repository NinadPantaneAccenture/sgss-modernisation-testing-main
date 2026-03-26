# Security Guidelines

## Environment Variables

This project uses environment variables to manage sensitive configuration. **Never commit credentials to version control.**

### Setup Instructions

1. Copy `.env.example` to `.env` in the project root:
   ```bash
   cp .env.example .env
   ```

2. Fill in your actual values in `.env`:
   ```bash
   AWS_ACCESS_KEY_ID=your_actual_key
   AWS_SECRET_ACCESS_KEY=your_actual_secret
   # etc...
   ```

3. **Ensure `.env` is in your `.gitignore`** (already configured)

### Never Commit

- ❌ `.env` files with real credentials
- ❌ AWS access keys or secret keys in code
- ❌ Database passwords
- ❌ Any sensitive configuration

### AWS Credential Management

If you've exposed credentials to GitHub:

1. **Immediately rotate** the AWS keys in the AWS console
2. **Delete or disable** the compromised IAM user
3. **Create new credentials** for local development
4. Update your `.env` file with the new credentials

### CI/CD Pipeline

For GitHub Actions or other CI/CD tools, use GitHub Secrets instead:

1. Go to: Settings → Secrets and variables → Actions
2. Add your environment variables as secrets
3. Reference them in your workflow:
   ```yaml
   env:
     AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
     AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
   ```

### Best Practices

- ✅ Use `.env.example` as a template (safe to commit)
- ✅ Use AWS IAM roles when running in AWS
- ✅ Use AWS Secrets Manager for production
- ✅ Rotate credentials regularly
- ✅ Limit IAM permissions to minimum required
- ✅ Audit AWS credential usage in CloudTrail

## Configuration Management

All sensitive configuration is loaded via `aws_services/aws_config.py` which reads from environment variables using `python-dotenv`.

See `.env.example` for all required environment variables.
