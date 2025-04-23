// VPC module for Thrive DevOps Takehome
// Defines variables for public-only VPC (no NAT, cost-conscious)

variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDRs (unused, for compatibility)"
  type        = list(string)
  default     = []
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Whether to enable NAT Gateway (should be false for cost savings)"
  type        = bool
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Whether to use a single NAT Gateway (should be false for cost savings)"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
  default     = {}
}
