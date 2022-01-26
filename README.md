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
|------|-------------|------|---------|:-----:|
| allowed\_security\_groups | A list of Security Group ID's to allow access to. | `list` | `[]` | no |
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| backup\_retention\_period | How long to keep backups for (in days) | `number` | `7` | no |
| ca\_cert\_identifier | The identifier of the CA certificate for the DB instances | `string` | `""` | no |
| cloudwatch\_alarm\_actions | Actions for cloudwatch alarms. e.g. an SNS topic | `list(string)` | `[]` | no |
| cloudwatch\_alarm\_default\_thresholds | Override default thresholds for CloudWatch alarms. See cloudwatch\_alarm\_default\_thresholds in cloudwatch.tf for valid keys | `map(string)` | `{}` | no |
| cloudwatch\_create\_alarms | Whether to enable CloudWatch alarms - requires `cw_sns_topic` is specified | `bool` | `false` | no |
| create\_resources | Whether to create the Aurora cluster and related resources | `bool` | `true` | no |
| create\_timeout | Timeout used for Cluster creation | `string` | `"120m"` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | `string` | `"default.aurora5.6"` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use | `string` | `"default.aurora5.6"` | no |
| delete\_timeout | Timeout used for destroying cluster. This includes any cleanup task during the destroying process. | `string` | `"120m"` | no |
| deletion\_protection | The database can't be deleted when this value is set to true. | `bool` | `true` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| engine\_version | Aurora database engine version. | `string` | `"5.6.10a"` | no |
| extra\_security\_groups | A list of Security Group IDs to add to the cluster | `list` | `[]` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final-"` | no |
| identifier\_prefix | Prefix for cluster and instance identifier | `string` | `""` | no |
| instance\_type | Instance type to use | `string` | `"db.r4.large"` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected | `number` | `0` | no |
| name | Name given resources | `string` | n/a | yes |
| password | Master DB password | `string` | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | `string` | `false` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `""` | no |
| port | The port on which to accept connections | `string` | `""` | no |
| preferred\_backup\_window | When to perform DB backups | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance | `string` | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address | `bool` | `false` | no |
| reader\_endpoint\_suffix | Suffix for the Route53 record pointing to the cluster reader endpoint. Only used if route53\_zone\_id is passed also | `string` | `"-ro"` | no |
| replica\_autoscaling | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | `string` | `false` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | `string` | `70` | no |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | `string` | `300` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | `string` | `0` | no |
| replica\_scale\_min | Maximum number of replicas to allow scaling for | `string` | `1` | no |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | `string` | `300` | no |
| route53\_record\_appendix | Will be appended to the route53 record. Only used if route53\_zone\_id is passed also | `string` | `".rds"` | no |
| route53\_record\_ttl | TTL of route53 record. Only used if route53\_zone\_id is passed also | `string` | `60` | no |
| route53\_zone\_id | If specified a route53 record will be created | `string` | `""` | no |
| security\_group\_name\_prefix | Prefix for security group name | `string` | `"aurora-"` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from | `string` | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | `bool` | `false` | no |
| subnet\_ids | List of subnet IDs to use | `list(string)` | n/a | yes |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| update\_timeout | Timeout used for Cluster modifications | `string` | `"120m"` | no |
| username | Master DB username | `string` | `"root"` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_endpoint | The cluster endpoint |
| cluster\_id | The ID of the cluster |
| cluster\_master\_password | The master password |
| cluster\_master\_username | The master username |
| cluster\_port | The port |
| cluster\_reader\_endpoint | The cluster reader endpoint |
| security\_group\_id | The security group ID of the cluster |
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.autoscaling_read_replica_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.read_replica_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.aurora_replica_lag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_connections_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_connections_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_queue_depth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.freeable_memory_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.freeable_memory_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.swap_usage_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.swap_usage_writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_role.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.data_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_route53_record.data_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.default_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_id.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.snapshot_identifier](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.monitoring_rds_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Determines whether or not major version upgrades are permitted | `bool` | `false` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | A list of Security Group ID's to allow access to. | `list` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | How long to keep backups for (in days) | `number` | `7` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instances | `string` | `""` | no |
| <a name="input_cloudwatch_alarm_actions"></a> [cloudwatch\_alarm\_actions](#input\_cloudwatch\_alarm\_actions) | Actions for cloudwatch alarms. e.g. an SNS topic | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_alarm_default_thresholds"></a> [cloudwatch\_alarm\_default\_thresholds](#input\_cloudwatch\_alarm\_default\_thresholds) | Override default thresholds for CloudWatch alarms. See cloudwatch\_alarm\_default\_thresholds in cloudwatch.tf for valid keys | `map(string)` | `{}` | no |
| <a name="input_cloudwatch_create_alarms"></a> [cloudwatch\_create\_alarms](#input\_cloudwatch\_create\_alarms) | Whether to enable CloudWatch alarms - requires `cw_sns_topic` is specified | `bool` | `false` | no |
| <a name="input_create_data_reader"></a> [create\_data\_reader](#input\_create\_data\_reader) | Specifies if a data reader node is created. | `bool` | `false` | no |
| <a name="input_create_resources"></a> [create\_resources](#input\_create\_resources) | Whether to create the Aurora cluster and related resources | `bool` | `true` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Timeout used for Cluster creation | `string` | `"120m"` | no |
| <a name="input_data_reader_endpoint_suffix"></a> [data\_reader\_endpoint\_suffix](#input\_data\_reader\_endpoint\_suffix) | Suffix for the Route53 record pointing to the cluster data reader endpoint. Only used if route53\_zone\_id is passed also | `string` | `"-data-reader"` | no |
| <a name="input_data_reader_instance_type"></a> [data\_reader\_instance\_type](#input\_data\_reader\_instance\_type) | Instance type to use for data reader node | `string` | `"db.r4.large"` | no |
| <a name="input_data_reader_parameter_group_name"></a> [data\_reader\_parameter\_group\_name](#input\_data\_reader\_parameter\_group\_name) | Data reader node db parameter group | `string` | `""` | no |
| <a name="input_data_reader_route53_prefix"></a> [data\_reader\_route53\_prefix](#input\_data\_reader\_route53\_prefix) | If specified a data reader route53 record will be created | `string` | `""` | no |
| <a name="input_data_reader_route53_zone_id"></a> [data\_reader\_route53\_zone\_id](#input\_data\_reader\_route53\_zone\_id) | If specified a data reader route53 record will be created | `string` | `""` | no |
| <a name="input_data_reader_tags"></a> [data\_reader\_tags](#input\_data\_reader\_tags) | A map of tags to add to data reader resources. | `map(string)` | `{}` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | The name of a DB Cluster parameter group to use | `string` | `"default.aurora5.6"` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | The name of a DB parameter group to use | `string` | `"default.aurora5.6"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Timeout used for destroying cluster. This includes any cleanup task during the destroying process. | `string` | `"120m"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | The database can't be deleted when this value is set to true. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Aurora database engine version. | `string` | `"5.6.10a"` | no |
| <a name="input_extra_security_groups"></a> [extra\_security\_groups](#input\_extra\_security\_groups) | A list of Security Group IDs to add to the cluster | `list` | `[]` | no |
| <a name="input_final_snapshot_identifier_prefix"></a> [final\_snapshot\_identifier\_prefix](#input\_final\_snapshot\_identifier\_prefix) | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final-"` | no |
| <a name="input_identifier_prefix"></a> [identifier\_prefix](#input\_identifier\_prefix) | Prefix for cluster and instance identifier | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use | `string` | `"db.r4.large"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval (seconds) between points when Enhanced Monitoring metrics are collected | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Name given resources | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | Master DB password | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. | `string` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `""` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which to accept connections | `string` | `""` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | When to perform DB backups for the cluster | `string` | `"02:00-03:00"` | no |
| <a name="input_preferred_backup_window_instance"></a> [preferred\_backup\_window\_instance](#input\_preferred\_backup\_window\_instance) | When to perform DB backups for instances | `string` | `""` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | When to perform DB maintenance for the cluster | `string` | `"sun:05:00-sun:06:00"` | no |
| <a name="input_preferred_maintenance_window_instance"></a> [preferred\_maintenance\_window\_instance](#input\_preferred\_maintenance\_window\_instance) | When to perform DB maintenance for instances | `string` | `""` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the DB should have a public IP address | `bool` | `false` | no |
| <a name="input_reader_endpoint_suffix"></a> [reader\_endpoint\_suffix](#input\_reader\_endpoint\_suffix) | Suffix for the Route53 record pointing to the cluster reader endpoint. Only used if route53\_zone\_id is passed also | `string` | `"-ro"` | no |
| <a name="input_replica_autoscaling"></a> [replica\_autoscaling](#input\_replica\_autoscaling) | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | `string` | `false` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| <a name="input_replica_scale_cpu"></a> [replica\_scale\_cpu](#input\_replica\_scale\_cpu) | CPU usage to trigger autoscaling at | `string` | `70` | no |
| <a name="input_replica_scale_in_cooldown"></a> [replica\_scale\_in\_cooldown](#input\_replica\_scale\_in\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale in | `string` | `300` | no |
| <a name="input_replica_scale_max"></a> [replica\_scale\_max](#input\_replica\_scale\_max) | Maximum number of replicas to allow scaling for | `string` | `0` | no |
| <a name="input_replica_scale_min"></a> [replica\_scale\_min](#input\_replica\_scale\_min) | Maximum number of replicas to allow scaling for | `string` | `1` | no |
| <a name="input_replica_scale_out_cooldown"></a> [replica\_scale\_out\_cooldown](#input\_replica\_scale\_out\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale out | `string` | `300` | no |
| <a name="input_route53_record_appendix"></a> [route53\_record\_appendix](#input\_route53\_record\_appendix) | Will be appended to the route53 record. Only used if route53\_zone\_id is passed also | `string` | `".rds"` | no |
| <a name="input_route53_record_ttl"></a> [route53\_record\_ttl](#input\_route53\_record\_ttl) | TTL of route53 record. Only used if route53\_zone\_id is passed also | `string` | `60` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | If specified a route53 record will be created | `string` | `""` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | Prefix for security group name | `string` | `"aurora-"` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | DB snapshot to create this database from | `string` | `""` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the underlying storage layer should be encrypted | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to use | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Timeout used for Cluster modifications | `string` | `"120m"` | no |
| <a name="input_username"></a> [username](#input\_username) | Master DB username | `string` | `"root"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The cluster endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the cluster |
| <a name="output_cluster_master_password"></a> [cluster\_master\_password](#output\_cluster\_master\_password) | The master password |
| <a name="output_cluster_master_username"></a> [cluster\_master\_username](#output\_cluster\_master\_username) | The master username |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The port |
| <a name="output_cluster_reader_endpoint"></a> [cluster\_reader\_endpoint](#output\_cluster\_reader\_endpoint) | The cluster reader endpoint |
