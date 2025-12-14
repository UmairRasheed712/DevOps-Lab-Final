# Infrastructure (Terraform)

This folder provisions AWS networking, EKS, and PostgreSQL RDS required for the lab.

## Prerequisites
- AWS account with programmatic access.
- AWS CLI configured (`aws configure` or export `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`).
- Terraform >= 1.5.

## Usage
```sh
cd infra
terraform init
terraform plan -var="db_password=<strong_password>"
terraform apply -var="db_password=<strong_password>"
```

Key variables (override with `-var` or `.tfvars`):
- `aws_region` (default `us-east-1`)
- `aws_profile` (empty uses default CLI creds)
- `project_name` (resource prefix)
- `db_password` (required, no default)

After apply, export kubeconfig to talk to the cluster:
```sh
$(terraform output -raw eks_kubeconfig_command)
```

Destroy to clean up (required by exam instructions):
```sh
terraform destroy -var="db_password=<strong_password>"
```

Outputs include the RDS endpoint and the kubeconfig command. Securely store passwords via environment variables or a secrets manager; do not commit them.
