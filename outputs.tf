# ══════════════════════════════════════════════════════════════════════════════
# OUTPUTS
# FreshDirect — IT473 Capstone
# ══════════════════════════════════════════════════════════════════════════════

output "vpc_id" {
  description = "ID of the FreshDirect VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (ALB tier)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (database tier)"
  value       = aws_subnet.private[*].id
}

output "app_security_group_id" {
  description = "Security group ID for the application tier"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "Security group ID for the database tier"
  value       = aws_security_group.database.id
}

output "rds_cluster_endpoint" {
  description = "Writer endpoint for the RDS Aurora cluster"
  value       = aws_rds_cluster.aurora.endpoint
  sensitive   = true
}

output "rds_reader_endpoint" {
  description = "Reader endpoint for the RDS Aurora cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
  sensitive   = true
}

output "sns_topic_arn" {
  description = "ARN of the monitoring SNS topic"
  value       = aws_sns_topic.monitoring.arn
}

output "lambda_ai_agent_arn" {
  description = "ARN of the AI Operations Agent Lambda function"
  value       = aws_lambda_function.ai_agent.arn
}

output "lambda_ai_agent_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_ai_agent.arn
}

output "rds_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt RDS Aurora"
  value       = aws_kms_key.rds.arn
}

output "s3_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt S3"
  value       = aws_kms_key.s3.arn
}
