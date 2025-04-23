// Root Terraform configuration for AWS infrastructure
// Modular, production-style layout for VPC, EKS, IAM, ECR
// Reviewer notes: version pinning, remote backend stub, and module structure

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
  required_version = ">= 1.6.0"
  # Uncomment and configure for remote state in production
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "thrive-devops-takehome/terraform.tfstate"
  #   region = "us-east-1"
  #   encrypt = true
  #   dynamodb_table = "my-terraform-lock-table"
  # }
}

provider "aws" {
  region = var.aws_region
  # profile = var.aws_profile # Uncomment if using a named profile
}

// --- Infrastructure Modules ---

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = ["${var.aws_region}a", "${var.aws_region}b"] # 2 AZs for demo
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false   # No NAT gateway to avoid billing (see ADR-001)
  enable_dns_hostnames = true
  enable_dns_support   = true
  map_public_ip_on_launch = true

  tags = {
    Environment = var.environment
    Project     = "thrive-devops-takehome"
    ManagedBy   = "Terraform"
    CostCenter  = "devops-demo"
  }
  # NOTE: For this assignment, all EKS nodes are in public subnets for zero-cost. In production, use private subnets + NAT gateway or VPC endpoints (see ADR-001).
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "thrive-devops-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  authentication_mode = "API"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  enable_irsa     = true

  access_entries = {
    terraform_admin_user = {
      principal_arn = "arn:aws:iam::329178086857:user/terraform-admin"
      type          = "STANDARD" # For IAM users/roles

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster" # Grant access to the whole cluster
          }
        }
      }
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"] # Free-tier eligible, low-cost
    disk_size      = 10
    min_size       = 1
    max_size       = 2
    desired_size   = 1
  }

  eks_managed_node_groups = {
    default = {
      name           = "default"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      subnet_ids     = module.vpc.public_subnets
    }
  }

  tags = {
    Environment = var.environment
    Project     = "thrive-devops-takehome"
    ManagedBy   = "Terraform"
    CostCenter  = "devops-demo"
  }
}

module "iam" {
  source  = "terraform-aws-modules/iam/aws"
  version = "~> 5.0"
  # Example: create_irsa_roles = true
  # cluster_name      = module.eks.cluster_name
  # Add IRSA roles as needed for External Secrets, etc.
}

# --- EKS Access Entries ---
# Define the access entry for the Terraform user
resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = module.eks.cluster_name # Reference EKS module output
  principal_arn = "arn:aws:iam::329178086857:user/terraform-admin"
  type          = "STANDARD" # Optional, but explicit
  depends_on = [
    module.eks
  ]
}

# Associate the admin policy with the Terraform user's access entry
resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = module.eks.cluster_name # Reference EKS module output
  principal_arn = aws_eks_access_entry.terraform_admin.principal_arn # Reference the entry
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# Define the access entry for the GitHub Actions role
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = module.eks.cluster_name # Reference EKS module output
  principal_arn = "arn:aws:iam::329178086857:role/GitHubActions-ThriveDevOpsRole"
  type          = "STANDARD" # Optional, but explicit
  depends_on = [
    module.eks
  ]
}

# Associate the admin policy with the GitHub Actions role's access entry
resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = module.eks.cluster_name # Reference EKS module output
  principal_arn = aws_eks_access_entry.github_actions.principal_arn # Reference the entry
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# --- ECR ---
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name                = var.ecr_repository_name
  repository_image_tag_mutability = var.ecr_image_tag_mutability
  repository_image_scan_on_push   = var.ecr_image_scan_on_push

  # Minimal valid lifecycle policy: expire untagged images older than 14 days
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
  # Single-repo config: supported in both v1.x and v2.x
}

// --- Output Stubs ---

output "vpc_id" {
  description = "VPC ID for EKS and other resources"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "ECR repo URL for CI/CD image pushes"
  value       = module.ecr.repository_url
}

// --- End main.tf ---
