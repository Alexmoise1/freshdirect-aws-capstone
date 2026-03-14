# ══════════════════════════════════════════════════════════════════════════════
# SNS TOPIC AND CLOUDWATCH ALARMS
# FreshDirect — IT473 Capstone
# Owner: Tyler Kizer (Observability Lead)
# ══════════════════════════════════════════════════════════════════════════════

# ── SNS TOPIC ─────────────────────────────────────────────────────────────────

resource "aws_sns_topic" "monitoring" {
  name         = "${var.project_name}-monitoring-topic"
  display_name = "FreshDirect Operations Alerts"

  tags = {
    Name    = "${var.project_name}-monitoring-topic"
    Owner   = "Tyler Kizer"
    Purpose = "CloudWatch alarm notifications and AI Agent trigger"
  }
}

# Operations team email subscription
resource "aws_sns_topic_subscription" "ops_email" {
  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "email"
  endpoint  = var.ops_email
}

# Lambda AI Agent subscription — triggered on every alarm
resource "aws_sns_topic_subscription" "ai_agent" {
  topic_arn = aws_sns_topic.monitoring.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ai_agent.arn
}

# ── CLOUDWATCH ALARMS ─────────────────────────────────────────────────────────

# App Runner: CPU utilization
resource "aws_cloudwatch_metric_alarm" "app_runner_cpu" {
  alarm_name          = "${var.project_name}-app-runner-cpu-high"
  alarm_description   = "App Runner CPU utilization exceeded 70% for 5 consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AppRunner"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Name  = "${var.project_name}-app-runner-cpu-alarm"
    Owner = "Tyler Kizer"
  }
}

# App Runner: HTTP 5xx errors
resource "aws_cloudwatch_metric_alarm" "app_runner_5xx" {
  alarm_name          = "${var.project_name}-app-runner-5xx-errors"
  alarm_description   = "App Runner HTTP 5xx error rate exceeded 1 percent of requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Http5xxRequests"
  namespace           = "AWS/AppRunner"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Name  = "${var.project_name}-5xx-alarm"
    Owner = "Tyler Kizer"
  }
}

# RDS Aurora: CPU utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  alarm_description   = "RDS Aurora CPU utilization exceeded 75% for 5 consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Name  = "${var.project_name}-rds-cpu-alarm"
    Owner = "Tyler Kizer"
  }
}

# RDS Aurora: database connection count
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.project_name}-rds-connections-high"
  alarm_description   = "RDS Aurora connection count exceeded 80 percent of maximum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 800
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Name  = "${var.project_name}-rds-connections-alarm"
    Owner = "Tyler Kizer"
  }
}

# Lambda AI Agent: function errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-ai-agent-errors"
  alarm_description   = "AI Agent Lambda function reported execution errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.ai_agent.function_name
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]

  tags = {
    Name  = "${var.project_name}-lambda-errors-alarm"
    Owner = "Tyler Kizer"
  }
}

# ── CLOUDWATCH LOG GROUPS WITH RETENTION ────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_ai_agent" {
  name              = "/aws/lambda/${var.project_name}-ai-agent"
  retention_in_days = 60

  tags = {
    Name    = "${var.project_name}-ai-agent-logs"
    Owner   = "Tyler Kizer"
    Purpose = "AI Agent execution logs"
  }
}
