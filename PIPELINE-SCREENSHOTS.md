# CI/CD Pipeline - Visual Guide & Screenshots

## Pipeline Overview

This document provides a visual guide for understanding and capturing screenshots of the CI/CD pipeline execution.

## Pipeline Stages Summary

| Stage | Duration | Key Activities | Success Criteria |
|-------|----------|----------------|------------------|
| 1️⃣ Build & Test | ~3-5 min | Install deps, Run pytest, Generate coverage | All tests pass, >80% coverage |
| 2️⃣ Security & Linting | ~5-7 min | Flake8, Bandit, Trivy, Safety checks | No critical vulnerabilities |
| 3️⃣ Docker Build & Push | ~8-10 min | Build image, Push to ECR, Image scanning | Image pushed successfully |
| 4️⃣ Terraform Apply | ~12-15 min | Init, Plan, Apply infrastructure | Infrastructure provisioned |
| 5️⃣ Kubernetes Deploy | ~5-7 min | kubectl apply, Rollout verification | Pods running successfully |
| 6️⃣ Smoke Tests | ~2-3 min | Health checks, API tests, Load tests | All tests pass |

**Total Pipeline Duration:** ~35-47 minutes (first run with infrastructure provisioning)

## How to Capture Pipeline Screenshots

### 1. Navigate to GitHub Actions

```
https://github.com/YOUR_USERNAME/DevOps-Lab-Final/actions
```

### 2. Trigger the Pipeline

**Option A - Push to main:**
```bash
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main
```

**Option B - Manual trigger:**
1. Click on "Actions" tab
2. Select "CI/CD Pipeline - DevOps Final Lab" workflow
3. Click "Run workflow" button
4. Select branch (main)
5. Click "Run workflow"

### 3. Monitor Pipeline Execution

Click on the running workflow to see real-time progress:
- Green ✅ = Stage passed
- Yellow 🟡 = Stage in progress
- Red ❌ = Stage failed

## Screenshot Locations

### Screenshot 1: Pipeline Overview
**Location:** Actions → Workflow runs list
**Shows:**
- Workflow name
- Trigger event (push/manual)
- Branch name
- Commit message
- Overall status
- Duration

**Capture when:** After all stages complete

**Example view:**
```
✅ CI/CD Pipeline - DevOps Final Lab
   main - Trigger CI/CD pipeline
   #42 • Completed in 38m 24s
   All jobs completed successfully
```

### Screenshot 2: All Stages Passed
**Location:** Actions → Specific workflow run → Jobs
**Shows:**
- All 7 jobs (6 stages + notify)
- Each job's status (green checkmarks)
- Duration for each stage
- Dependencies between stages

**Capture when:** All stages show green checkmarks

**Jobs list should show:**
```
✅ Build & Test Application          (4m 32s)
✅ Security Scanning & Code Quality  (6m 18s)
✅ Build & Push Docker Image         (9m 45s)
✅ Provision Infrastructure          (14m 56s)
✅ Deploy Application to EKS         (6m 22s)
✅ Post-Deployment Smoke Tests       (2m 41s)
✅ Send Notifications                (0m 18s)
```

### Screenshot 3: Build & Test Stage Details
**Location:** Actions → Workflow → Build & Test job
**Shows:**
- Python setup
- Dependencies installation
- Test execution with results
- Coverage percentage
- Test artifacts

**Key lines to show:**
```
Run pytest tests/ -v --cov=api
==================== test session starts ====================
collected 45 items

tests/test_routes.py::test_health_check PASSED         [ 2%]
tests/test_routes.py::test_graphql_endpoint PASSED    [ 4%]
...
==================== 45 passed in 12.34s ====================

Coverage: 87%
```

### Screenshot 4: Security & Linting Results
**Location:** Actions → Workflow → Security Scanning job
**Shows:**
- Flake8 linting results
- Bandit security scan
- Trivy vulnerability scan
- Safety dependency check

**Key sections:**
```
Run Flake8 (Linting): ✅ 0 errors found
Run Bandit (Security): ✅ No issues found
Run Trivy Scanner: ✅ 0 critical, 2 medium vulnerabilities
Run Safety Check: ✅ All dependencies secure
```

### Screenshot 5: Docker Build & Push
**Location:** Actions → Workflow → Build & Push Docker Image job
**Shows:**
- Docker buildx setup
- ECR login
- Image build progress
- Image push confirmation
- Image tags

**Key output:**
```
Building Docker image...
[+] Building 156.3s (18/18) FINISHED
 => [internal] load build definition
 => => transferring dockerfile: 987B
 => [internal] load .dockerignore
 => [stage-1 1/8] FROM docker.io/library/python:3.11-slim
...
Successfully built abc123def456
Successfully pushed to ECR:
  110695445213.dkr.ecr.us-east-1.amazonaws.com/devops-final-api:main-1234567
```

### Screenshot 6: Terraform Infrastructure
**Location:** Actions → Workflow → Provision Infrastructure job
**Shows:**
- Terraform init
- Terraform plan summary
- Terraform apply results
- Created resources count
- Outputs (VPC ID, EKS cluster name, RDS endpoint)

**Key output:**
```
Terraform Init: ✅ Initialized successfully
Terraform Validate: ✅ Configuration is valid
Terraform Plan: 59 to add, 0 to change, 0 to destroy
Terraform Apply: ✅ Apply complete! Resources: 59 added

Outputs:
vpc_id = "vpc-0b1e8865282c1baf4"
eks_cluster_name = "devops-final-eks"
rds_endpoint = "devops-final-db.c8luk8essf1z.us-east-1.rds.amazonaws.com:5432"
```

### Screenshot 7: Kubernetes Deployment
**Location:** Actions → Workflow → Deploy Application to EKS job
**Shows:**
- kubectl configuration
- Namespace creation
- Secrets creation
- Deployments applied
- Rollout status
- Pod status

**Key output:**
```
Update kubeconfig: ✅ Added context for devops-final-eks
Create namespace: ✅ namespace/devops-final created
Create secrets: ✅ secret/app-secrets configured
Deploy to Kubernetes: ✅
  configmap/app-config configured
  deployment.apps/api-deployment configured
  service/api-service configured
Wait for deployment: ✅ deployment "api-deployment" successfully rolled out

NAME                             READY   STATUS    RESTARTS   AGE
pod/api-deployment-7d6f4c9-abc   1/1     Running   0          2m
pod/api-deployment-7d6f4c9-def   1/1     Running   0          2m
```

### Screenshot 8: Smoke Tests Results
**Location:** Actions → Workflow → Post-Deployment Smoke Tests job
**Shows:**
- Service endpoint retrieval
- Health check tests
- GraphQL endpoint tests
- Load testing results
- All tests passed confirmation

**Key output:**
```
Running Smoke Tests
Endpoint: http://a1234567890.us-east-1.elb.amazonaws.com

Test 1: Health Check                     ✓ Health endpoint returned 200 OK
Test 2: GraphQL Endpoint                 ✓ GraphQL endpoint is accessible
Test 3: GraphQL Introspection           ✓ Introspection query successful
Test 4: Test Resolver                   ✓ Test resolver query successful
Test 5: Response Time                   ✓ Response time acceptable: 145ms
Test 6: Load Test (10 requests)         ✓ All 10 concurrent requests successful
Test 7: Content-Type Header             ✓ Correct Content-Type header present
Test 8: Security Headers                ✓ Security headers present

========================================
All Smoke Tests Passed!
========================================
```

### Screenshot 9: Complete Pipeline View
**Location:** Actions → Workflow run (main page)
**Shows:**
- Workflow graph visualization
- All stages connected with arrows
- Green checkmarks on all stages
- Total execution time
- Triggered by information

**This is your MAIN SCREENSHOT for submission**

## Screenshot Best Practices

### For Submission:
1. **Capture full browser window** (include URL bar showing github.com)
2. **Ensure all stage names are visible**
3. **Show green checkmarks for all stages**
4. **Include timestamp/duration**
5. **Use high resolution** (at least 1920x1080)

### Recommended Tools:
- **Windows:** Snipping Tool (Win + Shift + S)
- **Mac:** Screenshot (Cmd + Shift + 4)
- **Browser:** Full-page screenshot extension
- **Professional:** ShareX, Greenshot, Lightshot

### Screenshot Naming Convention:
```
01-pipeline-overview.png
02-all-stages-passed.png
03-build-and-test.png
04-security-scanning.png
05-docker-build-push.png
06-terraform-infrastructure.png
07-kubernetes-deployment.png
08-smoke-tests.png
09-complete-pipeline-graph.png
```

## Troubleshooting Failed Stages

If any stage fails, capture:
1. **Error message screenshot**
2. **Full log output**
3. **Job details**

Common fixes:
- Re-run failed jobs
- Check GitHub secrets
- Verify AWS permissions
- Review error logs

## Pipeline Artifacts

After pipeline completes, download artifacts:

### Available Artifacts:
1. **test-results** - Test coverage HTML report
2. **security-reports** - Bandit, Safety, Trivy reports
3. **terraform-plan** - Infrastructure plan output

**To download:**
1. Go to workflow run
2. Scroll to bottom
3. Click on artifact name
4. Automatically downloads as ZIP

## Creating a Summary Document

### For Lab Report:

**Pipeline Execution Summary**

```markdown
# CI/CD Pipeline Execution Results

## Pipeline Information
- **Repository:** github.com/YOUR_USERNAME/DevOps-Lab-Final
- **Workflow:** CI/CD Pipeline - DevOps Final Lab
- **Run Number:** #42
- **Triggered by:** Push to main branch
- **Commit:** 1234567 - "Trigger CI/CD pipeline"
- **Date:** December 15, 2025
- **Total Duration:** 38 minutes 24 seconds
- **Status:** ✅ Success

## Stages Executed

| Stage | Status | Duration | Details |
|-------|--------|----------|---------|
| Build & Test | ✅ Passed | 4m 32s | 45 tests passed, 87% coverage |
| Security & Linting | ✅ Passed | 6m 18s | 0 critical issues found |
| Docker Build & Push | ✅ Passed | 9m 45s | Image pushed to ECR |
| Terraform Infrastructure | ✅ Passed | 14m 56s | 59 resources created |
| Kubernetes Deployment | ✅ Passed | 6m 22s | 2 pods running |
| Smoke Tests | ✅ Passed | 2m 41s | All 8 tests passed |

## Key Metrics
- **Test Coverage:** 87%
- **Security Vulnerabilities:** 0 critical, 2 medium
- **Docker Image Size:** 487 MB
- **Deployment Success Rate:** 100%
- **Application Response Time:** 145ms average

## Infrastructure Deployed
- VPC: vpc-0b1e8865282c1baf4
- EKS Cluster: devops-final-eks
- RDS Database: devops-final-db
- Application Endpoint: http://a1234567890.us-east-1.elb.amazonaws.com

## Conclusion
All pipeline stages completed successfully. Application is deployed and healthy.
```

## Verification Checklist

Before submitting screenshots:

- [ ] All 6 main stages show green checkmarks
- [ ] Notification job completed
- [ ] GitHub repository URL visible in screenshot
- [ ] Timestamp/duration visible
- [ ] No sensitive information exposed (secrets, passwords)
- [ ] High-quality, readable screenshots
- [ ] Screenshots organized and labeled
- [ ] Pipeline artifacts downloaded

## Additional Evidence

To strengthen your submission, include:

1. **Pipeline YAML file** - `.github/workflows/main.yml`
2. **Successful run URL** - Direct link to GitHub Actions run
3. **Application endpoint** - Deployed app URL with screenshot
4. **kubectl output** - Pod status from EKS cluster
5. **Terraform state** - Resource list
6. **Test coverage report** - HTML coverage report

## Live Demo Preparation

If demonstrating live:

1. Have browser tab ready with completed pipeline
2. Prepare to show each stage's logs
3. Access application endpoint in another tab
4. Have kubectl ready to show pod status
5. Prepare to trigger a new run if needed

---

**Pipeline Dashboard URL:**
```
https://github.com/YOUR_USERNAME/DevOps-Lab-Final/actions
```

**Direct Workflow URL:**
```
https://github.com/YOUR_USERNAME/DevOps-Lab-Final/actions/workflows/main.yml
```

---

For setup instructions, see [PIPELINE-SETUP.md](PIPELINE-SETUP.md)
For secrets configuration, see [GITHUB-SECRETS.md](GITHUB-SECRETS.md)
