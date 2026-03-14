variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
  default     = "freshdirect"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

# ── VPC ──────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ — database tier)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to deploy across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# ── RDS AURORA ───────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the Aurora database"
  type        = string
  default     = "freshdirect_db"
}

variable "db_master_username" {
  description = "Master username for RDS Aurora"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS Aurora instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

# ── LAMBDA AI AGENT ──────────────────────────────────────────────────────────

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 120
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "ops_email" {
  description = "Operations team email address for SNS notifications"
  type        = string
  default     = "ops-alerts@directfreshfoods.com"
}
