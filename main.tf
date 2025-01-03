locals {
  port                       = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  master_password            = var.password == "" ? random_id.master_password.b64_url : var.password
  create_enhanced_monitoring = var.create_resources && var.monitoring_interval > 0 ? true : false
  cluster_instance_count     = var.create_resources ? var.replica_autoscaling ? var.replica_scale_min : var.replica_count : 0
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 10
}

resource "aws_ssm_parameter" "superuser_password" {
  count     = var.create_resources && var.store_master_creds_ssm ? 1 : 0
  name      = "${var.prefix_master_creds_ssm}/${aws_rds_cluster.main[0].endpoint}/superuser/password"
  type      = "SecureString"
  value     = local.master_password
  overwrite = true
}

resource "aws_ssm_parameter" "superuser_name" {
  count     = var.create_resources && var.store_master_creds_ssm ? 1 : 0
  name      = "${var.prefix_master_creds_ssm}/${aws_rds_cluster.main[0].endpoint}/superuser/name"
  type      = "SecureString"
  value     = var.username
  overwrite = true
}

resource "aws_db_subnet_group" "main" {
  count       = var.create_resources ? 1 : 0
  name        = var.name
  description = "For Aurora cluster ${var.name}"
  subnet_ids  = var.subnet_ids
  tags = merge(
    var.tags,
    {
      "Name" = "aurora-${var.name}"
    },
  )
}

resource "aws_rds_cluster" "main" {
  count = var.create_resources ? 1 : 0

  allow_major_version_upgrade      = var.allow_major_version_upgrade
  cluster_identifier               = "${var.identifier_prefix}${var.name}"
  engine                           = var.engine
  engine_version                   = var.engine_version
  engine_mode                      = var.engine_mode
  kms_key_id                       = var.kms_key_id
  master_username                  = var.username
  master_password                  = local.master_password
  deletion_protection              = var.deletion_protection
  final_snapshot_identifier        = "${var.final_snapshot_identifier_prefix}${var.name}-${random_id.snapshot_identifier[0].hex}"
  skip_final_snapshot              = var.skip_final_snapshot
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  preferred_maintenance_window     = var.preferred_maintenance_window
  port                             = local.port
  db_instance_parameter_group_name = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  db_subnet_group_name             = aws_db_subnet_group.main[0].name
  vpc_security_group_ids           = concat([aws_security_group.main[0].id], var.extra_security_groups)
  snapshot_identifier              = var.snapshot_identifier
  storage_encrypted                = var.storage_encrypted
  apply_immediately                = var.apply_immediately
  db_cluster_parameter_group_name  = var.db_cluster_parameter_group_name
  enabled_cloudwatch_logs_exports  = var.enabled_cloudwatch_logs_exports
  tags                             = var.tags

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.instance_type == "db.serverless" ? [1] : []
    content {
      max_capacity = var.serverlessv2_max_capacity
      min_capacity = var.serverlessv2_min_capacity
    }
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count                           = local.cluster_instance_count
  identifier                      = "${var.name}-${count.index + 1}"
  cluster_identifier              = aws_rds_cluster.main[0].id
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_type
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = aws_db_subnet_group.main[0].name
  db_parameter_group_name         = var.db_parameter_group_name
  preferred_backup_window         = var.preferred_backup_window_instance
  preferred_maintenance_window    = var.preferred_maintenance_window_instance
  apply_immediately               = var.apply_immediately
  monitoring_role_arn             = join("", aws_iam_role.rds_enhanced_monitoring.*.arn)
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  promotion_tier                  = count.index + 1
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  ca_cert_identifier              = var.ca_cert_identifier
  tags                            = var.tags

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

resource "aws_rds_cluster_instance" "data_reader" {
  count                           = var.create_data_reader && var.create_resources ? 1 : 0
  identifier                      = "${var.name}-data-reader"
  cluster_identifier              = aws_rds_cluster.main[0].id
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.data_reader_instance_type
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = aws_db_subnet_group.main[0].name
  db_parameter_group_name         = var.data_reader_parameter_group_name
  preferred_backup_window         = var.preferred_backup_window_instance
  preferred_maintenance_window    = var.preferred_maintenance_window_instance
  apply_immediately               = var.apply_immediately
  monitoring_role_arn             = join("", aws_iam_role.rds_enhanced_monitoring.*.arn)
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  promotion_tier                  = 15
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  ca_cert_identifier              = var.ca_cert_identifier
  tags                            = merge(var.tags, var.data_reader_tags)

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

resource "random_id" "snapshot_identifier" {
  count       = var.create_resources ? 1 : 0
  byte_length = 4

  keepers = {
    id = var.name
  }
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count              = local.create_enhanced_monitoring ? 1 : 0
  name               = "rds-enhanced-monitoring-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.monitoring_rds_assume_role.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = local.create_enhanced_monitoring ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_appautoscaling_target" "read_replica_count" {
  count              = var.replica_autoscaling ? 1 : 0
  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = "cluster:${aws_rds_cluster.main[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "autoscaling_read_replica_count" {
  count              = var.replica_autoscaling ? 1 : 0
  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.main[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    scale_in_cooldown  = var.replica_scale_in_cooldown
    scale_out_cooldown = var.replica_scale_out_cooldown
    target_value       = var.replica_scale_cpu
  }

  depends_on = [aws_appautoscaling_target.read_replica_count]
}

resource "aws_security_group" "main" {
  count       = var.create_resources ? 1 : 0
  name        = "${var.security_group_name_prefix}${var.name}"
  description = "For Aurora cluster ${var.name}"
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "aurora-${var.name}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "default_ingress" {
  count                    = var.create_resources ? length(var.allowed_security_groups) : 0
  type                     = "ingress"
  from_port                = aws_rds_cluster.main[0].port
  to_port                  = aws_rds_cluster.main[0].port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.main[0].id
}
