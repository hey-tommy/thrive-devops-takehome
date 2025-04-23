output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "external_secrets_iam_role_arn" {
  description = "ARN of the IAM role for External Secrets Service Account"
  value       = aws_iam_role.external_secrets_role.arn
}
