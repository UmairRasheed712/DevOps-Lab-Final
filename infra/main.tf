data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name = "${var.project_name}-${random_string.suffix.result}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnets = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i + length(local.azs))]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

resource "aws_security_group" "db" {
  name        = "${local.name}-db-sg"
  description = "Allow Postgres from VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${local.name}-eks"
  cluster_version = var.eks_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_irsa                          = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.eks_node_instance_types
      desired_size   = var.eks_node_desired_size
      max_size       = var.eks_node_max_size
      min_size       = var.eks_node_min_size
    }
  }

  tags = var.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.3"

  identifier = "${local.name}-db"

  engine               = "postgres"
  engine_version       = var.rds_engine_version
  family               = var.rds_family
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  db_name              = var.rds_db_name
  username             = var.db_username
  password             = var.db_password
  port                 = 5432
  publicly_accessible  = false
  multi_az             = false
  storage_encrypted    = true
  skip_final_snapshot  = true
  apply_immediately    = true
  deletion_protection  = false

  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = var.tags
}
