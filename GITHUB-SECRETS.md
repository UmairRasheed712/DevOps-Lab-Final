# GitHub Secrets Configuration

## Required Secrets for CI/CD Pipeline

Navigate to: **Repository → Settings → Secrets and variables → Actions → New repository secret**

### 1. AWS_ACCESS_KEY_ID
```
Type: Secret
Value: Your AWS IAM Access Key ID
Example: AKIARTRPWOLO26ARUESL
```

**How to get:**
```bash
# If you have AWS CLI configured
aws configure get aws_access_key_id

# Or create new access key in AWS Console:
# IAM → Users → Your User → Security Credentials → Create Access Key
```

---

### 2. AWS_SECRET_ACCESS_KEY
```
Type: Secret
Value: Your AWS IAM Secret Access Key
Example: IWRzaaic3J7CeF5z1B4biF0LUDJtR8YraHq1D6zm
```

**How to get:**
```bash
# If you have AWS CLI configured
aws configure get aws_secret_access_key

# Or create new access key in AWS Console (shown only once during creation)
```

---

### 3. DB_PASSWORD
```
Type: Secret
Value: PostgreSQL database password
Example: DevOpsLabPassword2024!
```

**Requirements:**
- Minimum 8 characters
- Include uppercase, lowercase, numbers, and special characters
- Same password used in terraform.tfvars

**Current value from your deployment:**
```
DevOpsLabPassword2024!
```

---

### 4. JWT_SECRET
```
Type: Secret
Value: Secret key for JWT token generation
Example: super-secret-jwt-key-change-in-production
```

**Generate secure JWT secret:**
```bash
# Linux/Mac
openssl rand -hex 32

# Python
python -c "import secrets; print(secrets.token_hex(32))"

# PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
```

---

## Optional Secrets (for enhanced features)

### 5. CODECOV_TOKEN
```
Type: Secret
Value: Codecov.io upload token
```

Sign up at [codecov.io](https://codecov.io) and get token from repository settings.

---

### 6. SLACK_WEBHOOK
```
Type: Secret
Value: Slack webhook URL for notifications
Example: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX
```

**How to get:**
1. Go to your Slack workspace
2. Click on Apps → Add apps
3. Search for "Incoming WebHooks"
4. Add to workspace
5. Choose channel
6. Copy webhook URL

---

### 7. DOCKER_HUB_USERNAME (if using Docker Hub instead of ECR)
```
Type: Secret
Value: Your Docker Hub username
```

---

### 8. DOCKER_HUB_TOKEN (if using Docker Hub instead of ECR)
```
Type: Secret
Value: Docker Hub access token
```

---

## Step-by-Step: Adding Secrets to GitHub

### Via GitHub Web UI:

1. **Navigate to your repository on GitHub**
   ```
   https://github.com/YOUR_USERNAME/DevOps-Lab-Final
   ```

2. **Go to Settings**
   - Click on "Settings" tab (near the top right)

3. **Navigate to Secrets**
   - In left sidebar: Click "Secrets and variables"
   - Click "Actions"

4. **Add New Secret**
   - Click "New repository secret" (green button)
   - Name: Enter secret name (e.g., `AWS_ACCESS_KEY_ID`)
   - Value: Paste secret value
   - Click "Add secret"

5. **Repeat for all required secrets**

### Via GitHub CLI:

```bash
# Install GitHub CLI
# Windows: winget install --id GitHub.cli
# Mac: brew install gh
# Linux: Check https://github.com/cli/cli#installation

# Login to GitHub
gh auth login

# Add secrets
gh secret set AWS_ACCESS_KEY_ID
# Paste value when prompted

gh secret set AWS_SECRET_ACCESS_KEY
gh secret set DB_PASSWORD
gh secret set JWT_SECRET

# Or from file
gh secret set AWS_ACCESS_KEY_ID < access_key.txt
```

---

## Verification

### Check if secrets are configured:

```bash
# List all secrets (values are hidden)
gh secret list
```

**Expected output:**
```
AWS_ACCESS_KEY_ID        Updated 2025-12-15
AWS_SECRET_ACCESS_KEY    Updated 2025-12-15
DB_PASSWORD              Updated 2025-12-15
JWT_SECRET               Updated 2025-12-15
```

---

## Security Best Practices

### ✅ DO:
- Rotate secrets regularly (every 90 days)
- Use strong, unique passwords
- Enable secret scanning on repository
- Limit secret access to necessary workflows
- Use environment-specific secrets for prod/dev

### ❌ DON'T:
- Never commit secrets to code
- Don't share secrets in plain text
- Don't use default or weak passwords
- Don't reuse secrets across projects
- Don't log secret values

---

## Testing Secrets Configuration

After adding secrets, test them:

```bash
# Push a commit to trigger pipeline
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# Or manually trigger workflow
# GitHub → Actions → CI/CD Pipeline → Run workflow
```

---

## Troubleshooting

### Secret not found error:
```
Error: Input required and not supplied: aws-access-key-id
```

**Solution:**
- Verify secret name matches exactly (case-sensitive)
- Check secret is added to correct repository
- Ensure workflow has permission to access secrets

### Invalid credentials error:
```
Error: The security token included in the request is invalid
```

**Solution:**
- Verify AWS credentials are correct
- Check IAM user has required permissions
- Regenerate access keys if needed

### Secret value not updating:
**Solution:**
- Delete and recreate the secret
- Clear GitHub Actions cache
- Re-run workflow

---

## Rotating Secrets

### AWS Credentials Rotation:

```bash
# 1. Create new access key in AWS Console
aws iam create-access-key --user-name YOUR_IAM_USER

# 2. Update GitHub secret with new values
gh secret set AWS_ACCESS_KEY_ID
gh secret set AWS_SECRET_ACCESS_KEY

# 3. Test new credentials
# Run pipeline manually

# 4. Deactivate old access key
aws iam update-access-key --access-key-id OLD_KEY_ID --status Inactive --user-name YOUR_IAM_USER

# 5. After confirming new key works, delete old key
aws iam delete-access-key --access-key-id OLD_KEY_ID --user-name YOUR_IAM_USER
```

### Database Password Rotation:

```bash
# 1. Update password in RDS
aws rds modify-db-instance \
  --db-instance-identifier devops-final-db \
  --master-user-password "NewSecurePassword123!" \
  --apply-immediately

# 2. Update GitHub secret
gh secret set DB_PASSWORD

# 3. Update Kubernetes secret
kubectl create secret generic app-secrets \
  --from-literal=db-password="NewSecurePassword123!" \
  --namespace=devops-final \
  --dry-run=client -o yaml | kubectl apply -f -

# 4. Restart pods
kubectl rollout restart deployment/api-deployment -n devops-final
```

---

## Quick Setup Script

Save as `setup-secrets.sh`:

```bash
#!/bin/bash

echo "GitHub Secrets Setup Script"
echo "============================"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub CLI first:"
    gh auth login
fi

echo "Enter your AWS Access Key ID:"
read -s AWS_ACCESS_KEY_ID
gh secret set AWS_ACCESS_KEY_ID -b"$AWS_ACCESS_KEY_ID"

echo "Enter your AWS Secret Access Key:"
read -s AWS_SECRET_ACCESS_KEY
gh secret set AWS_SECRET_ACCESS_KEY -b"$AWS_SECRET_ACCESS_KEY"

echo "Enter your Database Password:"
read -s DB_PASSWORD
gh secret set DB_PASSWORD -b"$DB_PASSWORD"

echo "Enter your JWT Secret (or press Enter to generate):"
read -s JWT_SECRET
if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -hex 32)
    echo "Generated JWT Secret: $JWT_SECRET"
fi
gh secret set JWT_SECRET -b"$JWT_SECRET"

echo ""
echo "✅ All secrets configured successfully!"
echo ""
echo "Verify with: gh secret list"
```

**Usage:**
```bash
chmod +x setup-secrets.sh
./setup-secrets.sh
```

---

## Repository Settings Checklist

Beyond secrets, ensure these settings are configured:

### Actions Permissions:
- ✅ Enable "Allow all actions and reusable workflows"
- ✅ Set "Workflow permissions" to "Read and write permissions"

### Branch Protection (optional but recommended):
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging

---

## Your Current Configuration

Based on your setup:

```yaml
AWS_ACCESS_KEY_ID: AKIARTRPWOLO26ARUESL
AWS_SECRET_ACCESS_KEY: IWRzaaic3J7CeF5z1B4biF0LUDJtR8YraHq1D6zm
DB_PASSWORD: DevOpsLabPassword2024!
JWT_SECRET: <generate-new-secure-key>
```

**⚠️ Important:** After setting up the pipeline, consider rotating these credentials for security.

---

## Next Steps

1. ✅ Add all required secrets to GitHub
2. ✅ Verify secrets with `gh secret list`
3. ✅ Push code to trigger pipeline
4. ✅ Monitor pipeline execution in Actions tab
5. ✅ Review pipeline results

---

For more information, see [PIPELINE-SETUP.md](PIPELINE-SETUP.md)
