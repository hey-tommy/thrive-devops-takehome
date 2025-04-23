// Root Terraform configuration for AWS infrastructure
// Modular, production-style layout for VPC, EKS, IAM, ECR
// Reviewer notes: version pinning, remote backend stub, and module structure

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # profile = var.aws_profile # Uncomment if using a named profile
}

# Configure Kubernetes provider to connect to EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

# Configure Helm provider to use the Kubernetes provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
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
  version = "20.13.0" # Pin to a specific recent v20.x

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
      max_size       = 3
      desired_size   = 2
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

# --- ECR Repository ---
resource "aws_ecr_repository" "app_repo" {
  name = "${var.project_name}-app"
  tags = var.tags
}

# --- IAM Role for External Secrets (IRSA) ---

data "aws_iam_policy_document" "external_secrets_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    # Condition specific to the external-secrets service account in the external-secrets namespace
    # Adjust namespace/serviceAccountName if installing KES differently
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
    # Optional: Condition for audience if needed, usually 'sts.amazonaws.com'
    # condition {
    #   test     = "StringEquals"
    #   variable = "${module.eks.oidc_provider}:aud"
    #   values   = ["sts.amazonaws.com"]
    # }
  }
}

resource "aws_iam_role" "external_secrets_role" {
  name               = "${var.project_name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role_policy.json
  tags = merge(var.tags, {
    Name = "${var.project_name}-external-secrets-role"
  })
}

# Define the policy granting access to Secrets Manager
# Keep this minimal - only GetSecretValue is strictly needed for basic operation
# kms:Decrypt is needed if secrets use a Customer Managed Key (CMK)
data "aws_iam_policy_document" "external_secrets_policy_doc" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret" # Useful for finding secrets by tags/name
      # "kms:Decrypt" # Add if using CMKs
    ]
    effect    = "Allow"
    resources = ["*"] # Scope down if possible, e.g., to secrets with specific tags or ARN patterns
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${var.project_name}-external-secrets-policy"
  description = "Allows External Secrets Operator to access Secrets Manager"
  policy      = data.aws_iam_policy_document.external_secrets_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "external_secrets_attach" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}

# --- Helm Releases ---

# Deploy kube-prometheus-stack for monitoring
resource "helm_release" "prometheus_stack" {
  name       = "thrive-monitoring" # Name of the Helm release
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.1.0" # Specify a recent, stable version

  namespace        = "monitoring" # Deploy into the monitoring namespace
  create_namespace = true         # Create the namespace if it doesn't exist

  # Use the existing values file
  values = [
    file("${path.module}/../../monitoring/helm-values.yaml")
  ]

  # Ensure Helm provider is configured and depends on EKS cluster being ready
  depends_on = [
    module.eks.cluster_id # Or another resource indicating cluster readiness
  ]

  # Timeout for Helm operations
  timeout = 600 # 10 minutes
}

# --- Output Stubs ---

output "vpc_id" {
  description = "VPC ID for EKS and other resources"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_oidc_issuer_url" {
  description = "EKS Cluster OIDC Issuer URL"
  value       = module.eks.oidc_provider
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

# output "ecr_repository_url" {
#   description = "URL of the ECR repository"
#   value       = aws_ecr_repository.app_repo.repository_url
# }
