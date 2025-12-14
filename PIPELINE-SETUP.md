# CI/CD Pipeline Setup Guide

## Overview

This project uses GitHub Actions for a fully automated CI/CD pipeline with 6 main stages:

1. **Build & Test** - Unit tests with coverage reporting
2. **Security & Linting** - Code quality and vulnerability scanning
3. **Docker Build & Push** - Container image creation and registry push
4. **Terraform Apply** - Infrastructure provisioning on AWS
5. **Kubernetes Deploy** - Application deployment to EKS
6. **Smoke Tests** - Post-deployment validation

## Pipeline Architecture

```
┌─────────────────┐
│  Code Push to   │
│  GitHub (main)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 1: Build  │
│    & Test       │◄──── pytest, coverage
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 2:        │
│ Security &      │◄──── flake8, bandit, trivy
│ Linting         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 3: Docker │
│ Build & Push    │◄──── Build image → Push to ECR
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 4:        │
│ Terraform Apply │◄──── Provision VPC, EKS, RDS
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 5:        │
│ Kubernetes      │◄──── kubectl apply
│ Deploy          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Stage 6:        │
│ Smoke Tests     │◄──── Health checks, API tests
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Deployment    │
│    Complete     │
└─────────────────┘
```

## Prerequisites

### 1. GitHub Repository Setup

Push your code to GitHub:
```bash
git init
git add .
git commit -m "Initial commit with CI/CD pipeline"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/DevOps-Lab-Final.git
git push -u origin main
```

### 2. GitHub Secrets Configuration

Navigate to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add the following secrets:

#### Required Secrets:

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM user access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM user secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `DB_PASSWORD` | PostgreSQL database password | `YourSecurePassword123!` |
| `JWT_SECRET` | JWT token secret key | `your-super-secret-jwt-key` |

#### To add secrets:
1. Go to repository **Settings**
2. Click **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter name and value
5. Click **Add secret**

### 3. AWS IAM User Permissions

Your AWS IAM user needs the following permissions:
- `AmazonEC2FullAccess`
- `AmazonEKSFullAccess`
- `AmazonRDSFullAccess`
- `AmazonVPCFullAccess`
- `AmazonEC2ContainerRegistryFullAccess`
- `IAMFullAccess` (for EKS cluster role creation)

**Minimal IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "rds:*",
        "ecr:*",
        "iam:*",
        "kms:*",
        "logs:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. Amazon ECR Repository

The pipeline automatically creates an ECR repository, but you can create it manually:

```bash
aws ecr create-repository \
  --repository-name devops-final-api \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256
```

## Pipeline Stages Explained

### Stage 1: Build & Test
- Sets up Python environment
- Installs dependencies from `requirements.txt` and `requirements-dev.txt`
- Runs pytest with coverage reporting
- Uploads coverage reports to Codecov
- Archives test results as artifacts

**Local Testing:**
```bash
pytest tests/ -v --cov=api --cov-report=html
```

### Stage 2: Security & Linting
- **Black**: Code formatting check
- **isort**: Import sorting validation
- **Flake8**: Code linting (PEP 8 compliance)
- **Pylint**: Advanced code quality analysis
- **Bandit**: Security vulnerability scanning
- **Safety**: Dependency vulnerability check
- **Trivy**: Comprehensive security scanner

**Local Testing:**
```bash
flake8 api/ tests/
bandit -r api/
safety check
```

### Stage 3: Docker Build & Push
- Builds Docker image using multi-stage build
- Tags with commit SHA and branch name
- Pushes to Amazon ECR
- Scans image for vulnerabilities using Trivy
- Uses Docker layer caching for faster builds

**Local Testing:**
```bash
docker build -t devops-final-api:latest .
docker run -p 5000:5000 devops-final-api:latest
```

### Stage 4: Terraform Apply
- Validates Terraform configuration
- Plans infrastructure changes
- Applies changes on main branch only
- Provisions:
  - VPC with public/private subnets
  - EKS cluster with managed node group
  - RDS PostgreSQL database
  - Security groups and networking

**Local Testing:**
```bash
cd infra
terraform init
terraform plan -var="db_password=YourPassword"
terraform apply -var="db_password=YourPassword"
```

### Stage 5: Kubernetes Deploy
- Configures kubectl for EKS access
- Creates Kubernetes namespace
- Creates/updates Kubernetes secrets
- Deploys application components:
  - ConfigMaps
  - Secrets
  - PostgreSQL (if using in-cluster)
  - Redis
  - API deployment
  - Services
- Waits for successful rollout

**Local Testing:**
```bash
aws eks update-kubeconfig --name devops-final-eks --region us-east-1
kubectl apply -f k8s/ -n devops-final
kubectl rollout status deployment/api-deployment -n devops-final
```

### Stage 6: Smoke Tests
- Waits for pods to be ready
- Retrieves service endpoint
- Runs comprehensive smoke tests:
  - Health check endpoint
  - GraphQL endpoint availability
  - Introspection queries
  - Test resolvers
  - Response time checks
  - Concurrent request handling
  - Security headers validation

**Local Testing:**
```bash
chmod +x scripts/smoke-tests.sh
./scripts/smoke-tests.sh http://localhost:5000
```

## Triggering the Pipeline

### Automatic Triggers:
- **Push to main branch**: Runs full pipeline including deployment
- **Push to develop branch**: Runs build, test, and security stages
- **Pull request to main**: Runs all stages except deployment

### Manual Trigger:
1. Go to **Actions** tab in GitHub
2. Select **CI/CD Pipeline - DevOps Final Lab**
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow** button

## Monitoring Pipeline Execution

### Via GitHub UI:
1. Go to **Actions** tab
2. Click on a workflow run
3. View logs for each stage
4. Download artifacts (test results, security reports)

### Pipeline Artifacts:
- Test coverage reports (HTML)
- Security scan results (JSON, SARIF)
- Terraform plan outputs

## Viewing Pipeline Results

### Success Indicators:
- ✅ All stages show green checkmarks
- No failed jobs
- Smoke tests pass
- Application accessible at service endpoint

### Failure Handling:
- Red X on failed stage
- Click on failed job to view logs
- Download artifacts for detailed analysis
- Re-run failed jobs from GitHub Actions UI

## Common Issues and Solutions

### Issue 1: AWS Credentials Error
**Error:** `Unable to locate credentials`
**Solution:** Verify AWS secrets are correctly set in GitHub repository settings

### Issue 2: Terraform State Lock
**Error:** `Error acquiring the state lock`
**Solution:**
```bash
terraform force-unlock LOCK_ID
```

### Issue 3: EKS Authentication Fails
**Error:** `You must be logged in to the server`
**Solution:**
- Verify IAM user has EKS permissions
- Update aws-auth ConfigMap if needed

### Issue 4: Docker Image Push Fails
**Error:** `denied: Your authorization token has expired`
**Solution:**
- ECR login is automatic in pipeline
- Verify AWS credentials have ECR permissions

### Issue 5: Smoke Tests Fail
**Error:** `Connection refused`
**Solution:**
- Check pod status: `kubectl get pods -n devops-final`
- Check service: `kubectl get svc -n devops-final`
- View logs: `kubectl logs -l app=api -n devops-final`

## Pipeline Optimization

### Speed Improvements:
1. **Enable Docker layer caching** (already configured)
2. **Use pip caching** (already configured)
3. **Parallel job execution** (where possible)
4. **Conditional deployment** (main branch only)

### Cost Optimization:
1. Use spot instances for non-critical workloads
2. Scale down EKS nodes during off-hours
3. Use Terraform workspaces for dev/prod separation

## Environment Variables

The pipeline uses these environment variables (configurable in workflow file):

```yaml
env:
  PYTHON_VERSION: '3.11'
  TERRAFORM_VERSION: '1.5.0'
  AWS_REGION: 'us-east-1'
  EKS_CLUSTER_NAME: 'devops-final-eks'
  DOCKER_IMAGE_NAME: 'devops-final-api'
```

## Security Best Practices

1. ✅ Never commit secrets to repository
2. ✅ Use GitHub Secrets for sensitive data
3. ✅ Enable branch protection rules
4. ✅ Require PR reviews before merging
5. ✅ Use least-privilege IAM policies
6. ✅ Enable ECR image scanning
7. ✅ Run security scans in pipeline
8. ✅ Keep dependencies updated

## Pipeline Notifications

The pipeline includes a notification job that:
- Sends success notification on completion
- Sends failure notification if any stage fails
- Can be extended to integrate with:
  - Slack
  - Microsoft Teams
  - Email
  - PagerDuty

### Adding Slack Notifications:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Rollback Strategy

If deployment fails or smoke tests don't pass:

```bash
# Rollback Kubernetes deployment
kubectl rollout undo deployment/api-deployment -n devops-final

# Rollback to specific revision
kubectl rollout history deployment/api-deployment -n devops-final
kubectl rollout undo deployment/api-deployment -n devops-final --to-revision=2
```

## Testing the Pipeline Locally

### Using Act (GitHub Actions locally):
```bash
# Install act
brew install act  # macOS
choco install act  # Windows

# Run workflow
act -j build-and-test
```

## Maintenance

### Regular Tasks:
- Review and update dependencies monthly
- Monitor AWS costs
- Review security scan results
- Update Terraform providers
- Rotate AWS credentials quarterly

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Support

For issues or questions:
1. Check pipeline logs in GitHub Actions
2. Review this documentation
3. Check AWS CloudWatch logs
4. Review Kubernetes pod logs

---

**Pipeline Status Badge:**

Add to your README.md:
```markdown
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/DevOps-Lab-Final/workflows/CI%2FCD%20Pipeline%20-%20DevOps%20Final%20Lab/badge.svg)
```
