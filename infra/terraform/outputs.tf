output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role created for GitHub Actions OIDC authentication."
  value       = aws_iam_role.github_actions_role.arn
}
