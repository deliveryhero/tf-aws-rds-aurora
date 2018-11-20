locals {
  cloudwatch_alarm_default_thresholds = {
    "database_connections" = 500
    "cpu_utilization"      = 70
    "disk_queue_depth"     = 20
    "aurora_replica_lag"   = 2000
    "freeable_memory"      = 200000000
    "swap_usage"           = 100000000
  }

  cloudwatch_create_alarms = "${var.create_resources && var.cloudwatch_create_alarms == 1 ? 1 : 0}"
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-writer-DiskQueueDepth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "disk_queue_depth", local.cloudwatch_alarm_default_thresholds["disk_queue_depth"])}"
  alarm_description   = "RDS Maximum DiskQueueDepth for RDS aurora cluster ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-writer-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Sum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "database_connections", local.cloudwatch_alarm_default_thresholds["database_connections"])}"
  alarm_description   = "RDS Maximum connection for RDS aurora cluster ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-reader-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "database_connections", local.cloudwatch_alarm_default_thresholds["database_connections"])}"
  alarm_description   = "RDS Maximum connection for RDS aurora cluster ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-writer-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "cpu_utilization", local.cloudwatch_alarm_default_thresholds["cpu_utilization"])}"
  alarm_description   = "RDS CPU for RDS aurora cluster ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-reader-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "cpu_utilization", local.cloudwatch_alarm_default_thresholds["cpu_utilization"])}"
  alarm_description   = "RDS CPU for RDS aurora cluster ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-reader-AuroraReplicaLag"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "aurora_replica_lag", local.cloudwatch_alarm_default_thresholds["aurora_replica_lag"])}"
  alarm_description   = "RDS CPU for RDS aurora cluster ${aws_rds_cluster.main.id}"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "swap_usage_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-writer-SwapUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "swap_usage", local.cloudwatch_alarm_default_thresholds["swap_usage"])}"
  alarm_description   = "RDS swap usage for RDS aurora cluster ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "swap_usage_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-reader-SwapUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "swap_usage", local.cloudwatch_alarm_default_thresholds["swap_usage"])}"
  alarm_description   = "RDS swap usage for RDS aurora cluster ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-writer-FreeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "freeable_memory", local.cloudwatch_alarm_default_thresholds["freeable_memory"])}"
  alarm_description   = "RDS freeable memory for RDS aurora cluster ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "rds-${aws_rds_cluster.main.id}-reader-FreeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "freeable_memory", local.cloudwatch_alarm_default_thresholds["freeable_memory"])}"
  alarm_description   = "RDS freeable memory for RDS aurora cluster ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}
