# ══════════════════════════════════════════════════════════════════════════════
# LAMBDA FUNCTION — CLOUD OPERATIONS AI AGENT
# FreshDirect — IT473 Capstone
# Owner: Alex Moise (Architecture Lead)
# ══════════════════════════════════════════════════════════════════════════════

# ── LAMBDA FUNCTION ───────────────────────────────────────────────────────────

resource "aws_lambda_function" "ai_agent" {
  function_name = "${var.project_name}-ai-agent"
  description   = "Cloud Operations Autonomy Agent — receives CloudWatch alarms via SNS, queries metrics and logs, and uses the Claude API to generate structured incident reports"
  role          = aws_iam_role.lambda_ai_agent.arn

  # Deployment package — zip containing the agent Python code
  filename         = "${path.module}/lambda/ai_agent.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/ai_agent.zip")
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory

  # Concurrency — allow up to 10 simultaneous alarm investigations
  reserved_concurrent_executions = 10

  environment {
    variables = {
      PROJECT_NAME       = var.project_name
      SNS_TOPIC_ARN      = aws_sns_topic.monitoring.arn
      AWS_REGION_NAME    = var.aws_region
      LOG_LEVEL          = "INFO"
      # ANTHROPIC_API_KEY is stored in Secrets Manager and retrieved at runtime
      ANTHROPIC_SECRET_ARN = aws_secretsmanager_secret.anthropic_api_key.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_ai_agent,
    aws_cloudwatch_log_group.lambda_ai_agent
  ]

  tags = {
    Name    = "${var.project_name}-ai-agent"
    Owner   = "Alex Moise"
    Purpose = "Autonomous incident analysis and reporting"
  }
}

# ── SNS TRIGGER PERMISSION ───────────────────────────────────────────────────
# Allows SNS to invoke the Lambda function when an alarm fires

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_agent.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.monitoring.arn
}

# ── SECRETS MANAGER — ANTHROPIC API KEY ───────────────────────────────────────
# The Claude API key is never stored in environment variables directly.
# The Lambda function retrieves it at runtime from Secrets Manager.

resource "aws_secretsmanager_secret" "anthropic_api_key" {
  name                    = "${var.project_name}/anthropic-api-key"
  description             = "Anthropic Claude API key for the FreshDirect AI Operations Agent"
  recovery_window_in_days = 7

  tags = {
    Name    = "${var.project_name}-anthropic-api-key"
    Owner   = "Alex Moise"
    Purpose = "AI Agent Claude API authentication"
  }
}

# ── SECRETS MANAGER — DATABASE CREDENTIALS ───────────────────────────────────
# RDS Aurora master password is managed by Secrets Manager with auto-rotation.

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/db-credentials"
  description             = "RDS Aurora master credentials for FreshDirect database"
  recovery_window_in_days = 7

  tags = {
    Name    = "${var.project_name}-db-credentials"
    Owner   = "Chris Thomas"
    Purpose = "RDS Aurora authentication"
  }
}
