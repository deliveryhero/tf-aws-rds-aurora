# AWS RDS Aurora Terraform module

Terraform module which creates RDS Aurora resources on AWS.

These types of resources are supported:

* [RDS Cluster](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html)
* [RDS Cluster Instance](https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html)
* [DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [Application AutoScaling Policy](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html)
* [Application AutoScaling Target](https://www.terraform.io/docs/providers/aws/r/appautoscaling_target.html)

## Available features

- Autoscaling of replicas
- Enhanced Monitoring
- Optional cloudwatch alarms

## Usage

```hcl
module "db" {
  source                          = "terraform-aws-modules/rds-aurora/aws"
  name                            = "test-aurora-db-postgres96"
  engine                          = "aurora-postgresql"
  engine_version                  = "9.6.3"
  vpc_id                          = "vpc-12345678"
  subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
  azs                             = ["eu-west-1a", "eu-west-1b"]
  replica_count                   = 1
  allowed_security_groups         = ["sg-12345678"]
  instance_type                   = "db.r4.large"
  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Examples

- [PostgreSQL](examples/postgres): A simple example with VPC and PostgreSQL cluster.
- [MySQL](examples/mysql): A simple example with VPC and MySQL cluster.
- [Production](examples/production): A production ready PostgreSQL cluster with enhanced monitoring, autoscaling and cloudwatch alarms.

## Documentation generation

Documentation should be modified within `main.tf` and generated using [terraform-docs](https://github.com/segmentio/terraform-docs).
Generate them like so:

```bash
go get github.com/segmentio/terraform-docs
terraform-docs md ./ | cat -s | tail -r | tail -n +2 | tail -r >> README.md
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed_security_groups | A list of Security Group ID's to allow access to. | string | `<list>` | no |
| apply_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | string | `false` | no |
| auto_minor_version_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | string | `true` | no |
| backup_retention_period | How long to keep backups for (in days) | string | `7` | no |
| cloudwatch_alarm_actions | Actions for cloudwatch alarms. e.g. an SNS topic | list | `<list>` | no |
| cloudwatch_alarm_default_thresholds | Override default thresholds for CloudWatch alarms. See cloudwatch_alarm_default_thresholds in cloudwatch.tf for valid keys | map | `<map>` | no |
| cloudwatch_create_alarms | Whether to enable CloudWatch alarms - requires `cw_sns_topic` is specified | string | `false` | no |
| create_resources | Whether to create the Aurora cluster and related resources | string | `true` | no |
| db_cluster_parameter_group_name | The name of a DB Cluster parameter group to use | string | `default.aurora5.6` | no |
| db_parameter_group_name | The name of a DB parameter group to use | string | `default.aurora5.6` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | string | `aurora` | no |
| engine_version | Aurora database engine version. | string | `5.6.10a` | no |
| final_snapshot_identifier_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | string | `final-` | no |
| identifier_prefix | Prefix for cluster and instance identifier | string | `` | no |
| instance_type | Instance type to use | string | `db.r4.large` | no |
| kms_key_id | The ARN for the KMS encryption key if one is set to the cluster. | string | `` | no |
| monitoring_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected | string | `0` | no |
| name | Name given resources | string | - | yes |
| password | Master DB password | string | `` | no |
| performance_insights_enabled | Specifies whether Performance Insights is enabled or not. | string | `false` | no |
| performance_insights_kms_key_id | The ARN for the KMS key to encrypt Performance Insights data. | string | `` | no |
| port | The port on which to accept connections | string | `` | no |
| preferred_backup_window | When to perform DB backups | string | `02:00-03:00` | no |
| preferred_maintenance_window | When to perform DB maintenance | string | `sun:05:00-sun:06:00` | no |
| publicly_accessible | Whether the DB should have a public IP address | string | `false` | no |
| replica_autoscaling | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | string | `false` | no |
| replica_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | string | `1` | no |
| replica_scale_cpu | CPU usage to trigger autoscaling at | string | `70` | no |
| replica_scale_in_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | string | `300` | no |
| replica_scale_max | Maximum number of replicas to allow scaling for | string | `0` | no |
| replica_scale_min | Maximum number of replicas to allow scaling for | string | `1` | no |
| replica_scale_out_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | string | `300` | no |
| route53_record_appendix | Will be appended to the route53 record. Only used if route53_zone_id is passed also | string | `.rds` | no |
| route53_record_ttl | TTL of route53 record. Only used if route53_zone_id is passed also | string | `60` | no |
| route53_zone_id | If specified a route53 record will be created | string | `` | no |
| security_group_name_prefix | Prefix for security group name | string | `aurora-` | no |
| skip_final_snapshot | Should a final snapshot be created on cluster destroy | string | `false` | no |
| snapshot_identifier | DB snapshot to create this database from | string | `` | no |
| storage_encrypted | Specifies whether the underlying storage layer should be encrypted | string | `false` | no |
| subnet_ids | List of subnet IDs to use | list | - | yes |
| tags | A map of tags to add to all resources. | map | `<map>` | no |
| username | Master DB username | string | `root` | no |
| vpc_id | VPC ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | The cluster endpoint |
| cluster_id | The ID of the cluster |
| cluster_master_password | The master password |
| cluster_master_username | The master username |
| cluster_port | The port |
| cluster_reader_endpoint | The cluster reader endpoint |
| security_group_id | The security group ID of the cluster |
