# AWS Configuration
aws_region  = "us-east-1"
aws_profile = ""

# Project Configuration
project_name = "devops-final"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
azs      = ["us-east-1a", "us-east-1b"]

# EKS Configuration
eks_version              = "1.29"
eks_node_instance_types  = ["t3.small"]
eks_node_desired_size    = 1
eks_node_max_size        = 1
eks_node_min_size        = 1

# RDS Configuration
rds_instance_class    = "db.t3.micro"
rds_allocated_storage = 20
rds_engine_version    = "14.12"
rds_family            = "postgres14"
rds_db_name           = "pfaas_prod"
db_username           = "postgres"
db_password           = "DevOpsLabPassword2024!"  # Change this to a secure password

# Tags
tags = {
  ManagedBy   = "terraform"
  Project     = "devops-final"
  Environment = "production"
}
