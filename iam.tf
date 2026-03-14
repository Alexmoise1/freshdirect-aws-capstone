# ══════════════════════════════════════════════════════════════════════════════
# IAM ROLES AND POLICIES — LEAST PRIVILEGE
# FreshDirect — IT473 Capstone
# Owner: Alex Moise (Architecture Lead) / Mehak Saeed (Security Lead)
# ══════════════════════════════════════════════════════════════════════════════

# ── LAMBDA EXECUTION ROLE (AI AGENT) ─────────────────────────────────────────
# Scoped to only what the AI agent needs:
# - Read CloudWatch metrics and logs
# - Publish to SNS
# - Write its own execution logs

resource "aws_iam_role" "lambda_ai_agent" {
  name        = "${var.project_name}-lambda-ai-agent-role"
  description = "Execution role for the FreshDirect Cloud Operations AI Agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "${var.project_name}-lambda-ai-agent-role"
    Owner   = "Alex Moise"
    Purpose = "AI Operations Agent execution"
  }
}

resource "aws_iam_policy" "lambda_ai_agent" {
  name        = "${var.project_name}-lambda-ai-agent-policy"
  description = "Least-privilege policy for the FreshDirect AI Operations Agent"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchMetricsRead"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsRead"
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/apprunner/*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/rds/*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}*"
        ]
      },
      {
        Sid    = "SNSPublish"
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = [aws_sns_topic.monitoring.arn]
      },
      {
        Sid    = "LambdaBasicExecution"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}*"
      }
    ]
  })

  tags = {
    Name  = "${var.project_name}-lambda-ai-agent-policy"
    Owner = "Alex Moise"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_ai_agent" {
  role       = aws_iam_role.lambda_ai_agent.name
  policy_arn = aws_iam_policy.lambda_ai_agent.arn
}

# ── APP RUNNER SERVICE ROLE ───────────────────────────────────────────────────
# Allows App Runner to pull images and access Secrets Manager at runtime.
# Does NOT grant database or S3 access directly.

resource "aws_iam_role" "app_runner" {
  name        = "${var.project_name}-app-runner-role"
  description = "Service role for FreshDirect App Runner instances"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name    = "${var.project_name}-app-runner-role"
    Owner   = "Chris Thomas"
    Purpose = "App Runner instance role"
  }
}

resource "aws_iam_policy" "app_runner" {
  name        = "${var.project_name}-app-runner-policy"
  description = "Least-privilege policy for FreshDirect App Runner service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project_name}/*"
      },
      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/apprunner/*"
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          aws_kms_key.rds.arn,
          aws_kms_key.s3.arn
        ]
      }
    ]
  })

  tags = {
    Name  = "${var.project_name}-app-runner-policy"
    Owner = "Chris Thomas"
  }
}

resource "aws_iam_role_policy_attachment" "app_runner" {
  role       = aws_iam_role.app_runner.name
  policy_arn = aws_iam_policy.app_runner.arn
}

# ── KMS KEY FOR S3 ───────────────────────────────────────────────────────────

resource "aws_kms_key" "s3" {
  description             = "KMS key for FreshDirect S3 encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name    = "${var.project_name}-s3-kms-key"
    Purpose = "S3 encryption at rest"
    Owner   = "Mehak Saeed"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-s3"
  target_key_id = aws_kms_key.s3.key_id
}
