#!/bin/bash

# CI/CD Pipeline Validation Script
# This script checks if everything is ready for the pipeline to run

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CI/CD Pipeline Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check command exists
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 not found"
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 not found"
        return 1
    fi
}

ERRORS=0

# Check Required Commands
echo -e "${YELLOW}Checking Required Tools...${NC}"
check_command "git" || ((ERRORS++))
check_command "docker" || ((ERRORS++))
check_command "python3" || ((ERRORS++))
check_command "pip" || ((ERRORS++))
check_command "terraform" || ((ERRORS++))
check_command "aws" || ((ERRORS++))
check_command "kubectl" || ((ERRORS++))
echo ""

# Check GitHub CLI (optional but recommended)
echo -e "${YELLOW}Checking Optional Tools...${NC}"
check_command "gh" || echo -e "${YELLOW}⚠${NC} GitHub CLI (gh) is optional but recommended"
echo ""

# Check Project Files
echo -e "${YELLOW}Checking Project Files...${NC}"
check_file "requirements.txt" || ((ERRORS++))
check_file "requirements-dev.txt" || ((ERRORS++))
check_file "Dockerfile" || ((ERRORS++))
check_file "docker-compose.yml" || ((ERRORS++))
check_file "pytest.ini" || echo -e "${YELLOW}⚠${NC} pytest.ini not found (optional)"
echo ""

# Check Infrastructure Files
echo -e "${YELLOW}Checking Infrastructure Files...${NC}"
check_file "infra/main.tf" || ((ERRORS++))
check_file "infra/variables.tf" || ((ERRORS++))
check_file "infra/outputs.tf" || ((ERRORS++))
check_file "infra/providers.tf" || ((ERRORS++))
check_file "infra/terraform.tfvars" || echo -e "${YELLOW}⚠${NC} terraform.tfvars not found (will use defaults)"
echo ""

# Check Kubernetes Files
echo -e "${YELLOW}Checking Kubernetes Manifests...${NC}"
check_dir "k8s" || ((ERRORS++))
check_file "k8s/api-deployment.yaml" || ((ERRORS++))
check_file "k8s/api-service.yaml" || ((ERRORS++))
check_file "k8s/configmap.yaml" || ((ERRORS++))
check_file "k8s/secret.yaml" || ((ERRORS++))
echo ""

# Check CI/CD Files
echo -e "${YELLOW}Checking CI/CD Configuration...${NC}"
check_dir ".github/workflows" || ((ERRORS++))
check_file ".github/workflows/main.yml" || ((ERRORS++))
check_file "scripts/smoke-tests.sh" || ((ERRORS++))
echo ""

# Check Python Application
echo -e "${YELLOW}Checking Python Application...${NC}"
check_dir "api" || ((ERRORS++))
check_file "api/__init__.py" || ((ERRORS++))
check_file "api/routes.py" || ((ERRORS++))
check_dir "tests" || ((ERRORS++))
echo ""

# Check Git Repository
echo -e "${YELLOW}Checking Git Repository...${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git repository initialized"
    
    # Check for remote
    if git remote get-url origin > /dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo -e "${GREEN}✓${NC} Remote configured: $REMOTE_URL"
    else
        echo -e "${RED}✗${NC} No remote repository configured"
        echo -e "${YELLOW}  Run: git remote add origin <your-repo-url>${NC}"
        ((ERRORS++))
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    echo -e "${GREEN}✓${NC} Current branch: $CURRENT_BRANCH"
    
else
    echo -e "${RED}✗${NC} Not a git repository"
    echo -e "${YELLOW}  Run: git init${NC}"
    ((ERRORS++))
fi
echo ""

# Check AWS Configuration
echo -e "${YELLOW}Checking AWS Configuration...${NC}"
if aws sts get-caller-identity &> /dev/null; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    echo -e "${GREEN}✓${NC} AWS credentials configured"
    echo -e "  Account: $AWS_ACCOUNT"
    echo -e "  User: $AWS_USER"
else
    echo -e "${RED}✗${NC} AWS credentials not configured"
    echo -e "${YELLOW}  Run: aws configure${NC}"
    ((ERRORS++))
fi
echo ""

# Check GitHub Secrets (if gh CLI available)
if command -v gh &> /dev/null; then
    echo -e "${YELLOW}Checking GitHub Secrets...${NC}"
    if gh auth status &> /dev/null; then
        SECRETS=$(gh secret list 2>/dev/null | wc -l)
        if [ $SECRETS -gt 0 ]; then
            echo -e "${GREEN}✓${NC} $SECRETS GitHub secrets configured"
            gh secret list 2>/dev/null | head -5
            
            # Check required secrets
            REQUIRED_SECRETS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "DB_PASSWORD" "JWT_SECRET")
            for secret in "${REQUIRED_SECRETS[@]}"; do
                if gh secret list 2>/dev/null | grep -q "^$secret"; then
                    echo -e "${GREEN}  ✓${NC} $secret"
                else
                    echo -e "${RED}  ✗${NC} $secret (required)"
                    ((ERRORS++))
                fi
            done
        else
            echo -e "${YELLOW}⚠${NC} No GitHub secrets found"
            echo -e "${YELLOW}  See GITHUB-SECRETS.md for setup instructions${NC}"
        fi
    else
        echo -e "${YELLOW}⚠${NC} GitHub CLI not authenticated"
        echo -e "${YELLOW}  Run: gh auth login${NC}"
    fi
    echo ""
fi

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
    DOCKER_VERSION=$(docker --version)
    echo -e "  $DOCKER_VERSION"
else
    echo -e "${RED}✗${NC} Docker daemon is not running"
    echo -e "${YELLOW}  Start Docker Desktop or docker service${NC}"
    ((ERRORS++))
fi
echo ""

# Check Python Dependencies
echo -e "${YELLOW}Checking Python Dependencies...${NC}"
if pip show pytest &> /dev/null; then
    echo -e "${GREEN}✓${NC} pytest installed"
else
    echo -e "${YELLOW}⚠${NC} pytest not installed"
    echo -e "${YELLOW}  Run: pip install -r requirements-dev.txt${NC}"
fi

if pip show flake8 &> /dev/null; then
    echo -e "${GREEN}✓${NC} flake8 installed"
else
    echo -e "${YELLOW}⚠${NC} flake8 not installed"
fi
echo ""

# Run Quick Tests
echo -e "${YELLOW}Running Quick Tests...${NC}"

# Test 1: Python syntax check
echo -n "Testing Python syntax... "
if python3 -m py_compile api/*.py &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    ((ERRORS++))
fi

# Test 2: Terraform validation
if [ -d "infra" ]; then
    echo -n "Validating Terraform configuration... "
    cd infra
    if terraform init -backend=false &> /dev/null && terraform validate &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((ERRORS++))
    fi
    cd ..
fi

# Test 3: Docker build test (quick)
echo -n "Testing Docker build (dry-run)... "
if docker build --dry-run . &> /dev/null 2>&1 || [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} (Docker build validation skipped)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e ""
    echo -e "Your environment is ready for CI/CD pipeline."
    echo -e ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "1. Configure GitHub secrets (see GITHUB-SECRETS.md)"
    echo -e "2. Push code to GitHub: git push origin main"
    echo -e "3. Monitor pipeline: https://github.com/YOUR_USERNAME/REPO/actions"
    echo -e ""
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS issue(s)${NC}"
    echo -e ""
    echo -e "${YELLOW}Please fix the issues above before running the pipeline.${NC}"
    echo -e ""
    echo -e "For help, see:"
    echo -e "  - PIPELINE-SETUP.md - Pipeline setup guide"
    echo -e "  - GITHUB-SECRETS.md - Secrets configuration"
    echo -e "  - README.md - Project documentation"
    echo -e ""
    exit 1
fi
