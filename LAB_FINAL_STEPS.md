# Lab Final Steps (1-5)

This guide tracks what is completed for the lab exam through Step 5 and what you need to run on your side.

## Step 1 – Project + Containerization
- Dockerfiles already present for API/frontend.
- `docker-compose.yml` now runs API + PostgreSQL + Redis with persistent volume for Postgres.
- Health endpoint `/healthcheck` verifies DB and Redis.
- Local run:
  ```sh
  cp .env-SAMPLE .env  # adjust if needed
  docker-compose up -d --build
  docker-compose logs -f api
  ```

## Step 2 – Terraform (AWS)
- Code in `infra/` provisions VPC, public/private subnets, EKS, and RDS (PostgreSQL).
- You must supply AWS credentials and `db_password` when running Terraform.
- Commands (from `infra/`):
  ```sh
  terraform init
  terraform plan -var="db_password=<strong_password>"
  terraform apply -var="db_password=<strong_password>"
  $(terraform output -raw eks_kubeconfig_command)
  ```
- Destroy after screenshots:
  ```sh
  terraform destroy -var="db_password=<strong_password>"
  ```

## Step 4 – Ansible
- Playbook in `ansible/playbook.yaml` applies the Kubernetes manifests using your kubeconfig.
- Install dependencies and run:
  ```sh
  cd ansible
  ansible-galaxy collection install -r requirements.yml
  ansible-playbook -i inventory.ini playbook.yaml
  ```

## Step 5 – Kubernetes Deployment
- Manifests in `k8s/` for API, Postgres (stateful), and Redis.
- Update API image in `k8s/api-deployment.yaml` after you push to a registry (ECR/GHCR/Docker Hub).
- Optional: adjust `SECRET_KEY` and `POSTGRES_PASSWORD` in `k8s/secret.yaml` before applying.
- Apply manually (alternative to Ansible):
  ```sh
  kubectl apply -f k8s/configmap.yaml -f k8s/secret.yaml
  kubectl apply -f k8s/postgres.yaml -f k8s/redis.yaml
  kubectl apply -f k8s/api-deployment.yaml -f k8s/api-service.yaml
  kubectl get pods -n dev
  kubectl get svc -n dev
  kubectl describe pod <pod> -n dev
  ```

## What you must do
- Provide AWS credentials/profile and choose region for Terraform.
- Push API image to a registry and update the image name in `k8s/api-deployment.yaml`.
- Swap secrets to strong values (do not commit real secrets).
- Capture required screenshots (Terraform outputs/AWS console, kubectl get pods/svc/describe, Ansible run).
