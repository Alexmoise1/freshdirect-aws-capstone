# ══════════════════════════════════════════════════════════════════════════════
# RDS AURORA — MULTI-AZ DATABASE CLUSTER
# FreshDirect — IT473 Capstone
# Owner: Alex Moise (Architecture Lead)
# ══════════════════════════════════════════════════════════════════════════════

# ── KMS KEY FOR ENCRYPTION AT REST ───────────────────────────────────────────

resource "aws_kms_key" "rds" {
  description             = "KMS key for FreshDirect RDS Aurora encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name    = "${var.project_name}-rds-kms-key"
    Purpose = "RDS encryption at rest"
    Owner   = "Mehak Saeed"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# ── DB SUBNET GROUP ───────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for FreshDirect Aurora cluster across 3 AZs"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ── RDS AURORA CLUSTER ────────────────────────────────────────────────────────

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.1"
  database_name           = var.db_name
  master_username         = var.db_master_username
  manage_master_user_password = true          # Secrets Manager handles the password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  # Encryption at rest using customer-managed KMS key
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  # Automated backups — 7-day retention
  backup_retention_period = var.db_backup_retention_days
  preferred_backup_window = "03:00-04:00"

  # Maintenance window — low-traffic period
  preferred_maintenance_window = "sun:05:00-sun:06:00"

  # Deletion protection — prevents accidental removal in production
  deletion_protection = true

  # Skip final snapshot only for dev; always take one in production
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-aurora-final-snapshot"

  tags = {
    Name = "${var.project_name}-aurora-cluster"
  }
}

# ── AURORA INSTANCES (writer + reader in separate AZs) ───────────────────────

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.project_name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  availability_zone          = var.availability_zones[0]
  db_subnet_group_name       = aws_db_subnet_group.main.name
  publicly_accessible        = false
  auto_minor_version_upgrade = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "${var.project_name}-aurora-writer"
    Role = "writer"
  }
}

resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.project_name}-aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  # Reader placed in a different AZ than the writer for Multi-AZ failover
  availability_zone          = var.availability_zones[1]
  db_subnet_group_name       = aws_db_subnet_group.main.name
  publicly_accessible        = false
  auto_minor_version_upgrade = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "${var.project_name}-aurora-reader"
    Role = "reader"
  }
}

# ── RDS ENHANCED MONITORING ROLE ─────────────────────────────────────────────

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name  = "${var.project_name}-rds-monitoring-role"
    Owner = "Alex Moise"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
