locals {
  cloudwatch_alarm_default_thresholds = {
    "database_connections" = 500
    "cpu_utilization"      = 70
    "disk_queue_depth"     = 20
    "aurora_replica_lag"   = 2000
  }

  cloudwatch_create_alarms = "${var.create_resources && var.cloudwatch_create_alarms == 1 ? 1 : 0}"
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-writer-DiskQueueDepth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "disk_queue_depth", local.cloudwatch_alarm_default_thresholds["disk_queue_depth"])}"
  alarm_description   = "RDS Maximum DiskQueueDepth Alarm for ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-writer-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Sum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "database_connections", local.cloudwatch_alarm_default_thresholds["database_connections"])}"
  alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-reader-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "database_connections", local.cloudwatch_alarm_default_thresholds["database_connections"])}"
  alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_writer" {
  count               = "${local.cloudwatch_create_alarms}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-writer-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "cpu_utilization", local.cloudwatch_alarm_default_thresholds["cpu_utilization"])}"
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.main.id} writer"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_reader" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-reader-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "cpu_utilization", local.cloudwatch_alarm_default_thresholds["cpu_utilization"])}"
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.main.id} reader(s)"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  count               = "${local.cloudwatch_create_alarms && var.replica_count > 0 ? 1 : 0}"
  alarm_name          = "${aws_rds_cluster.main.id}-alarm-rds-reader-AuroraReplicaLag"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${lookup(var.cloudwatch_alarm_default_thresholds, "aurora_replica_lag", local.cloudwatch_alarm_default_thresholds["aurora_replica_lag"])}"
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.main.id}"
  alarm_actions       = ["${var.cloudwatch_alarm_actions}"]
  ok_actions          = ["${var.cloudwatch_alarm_actions}"]

  dimensions {
    DBClusterIdentifier = "${aws_rds_cluster.main.id}"
    Role                = "READER"
  }
}
