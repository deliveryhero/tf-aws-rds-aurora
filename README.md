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
| allowed\_security\_groups | A list of Security Group ID's to allow access to. | list | `<list>` | no |
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | string | `"false"` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | string | `"true"` | no |
| backup\_retention\_period | How long to keep backups for (in days) | string | `"7"` | no |
| cloudwatch\_alarm\_actions | Actions for cloudwatch alarms. e.g. an SNS topic | list | `<list>` | no |
| cloudwatch\_alarm\_default\_thresholds | Override default thresholds for CloudWatch alarms. See cloudwatch_alarm_default_thresholds in cloudwatch.tf for valid keys | map | `<map>` | no |
| cloudwatch\_create\_alarms | Whether to enable CloudWatch alarms - requires `cw_sns_topic` is specified | string | `"false"` | no |
| create\_resources | Whether to create the Aurora cluster and related resources | string | `"true"` | no |
| create\_timeout | Timeout used for Cluster creation | string | `"120m"` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | string | `"default.aurora5.6"` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use | string | `"default.aurora5.6"` | no |
| delete\_timeout | Timeout used for destroying cluster. This includes any cleanup task during the destroying process. | string | `"120m"` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | string | `"aurora"` | no |
| engine\_version | Aurora database engine version. | string | `"5.6.10a"` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | string | `"final-"` | no |
| identifier\_prefix | Prefix for cluster and instance identifier | string | `""` | no |
| instance\_type | Instance type to use | string | `"db.r4.large"` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | string | `""` | no |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected | string | `"0"` | no |
| name | Name given resources | string | n/a | yes |
| password | Master DB password | string | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | string | `"false"` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data. | string | `""` | no |
| port | The port on which to accept connections | string | `""` | no |
| preferred\_backup\_window | When to perform DB backups | string | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance | string | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address | string | `"false"` | no |
| reader\_endpoint\_suffix | Suffix for the Route53 record pointing to the cluster reader endpoint. Only used if route53_zone_id is passed also | string | `"-ro"` | no |
| replica\_autoscaling | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | string | `"false"` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | string | `"1"` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | string | `"70"` | no |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | string | `"300"` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | string | `"0"` | no |
| replica\_scale\_min | Maximum number of replicas to allow scaling for | string | `"1"` | no |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | string | `"300"` | no |
| route53\_record\_appendix | Will be appended to the route53 record. Only used if route53_zone_id is passed also | string | `".rds"` | no |
| route53\_record\_ttl | TTL of route53 record. Only used if route53_zone_id is passed also | string | `"60"` | no |
| route53\_zone\_id | If specified a route53 record will be created | string | `""` | no |
| security\_group\_name\_prefix | Prefix for security group name | string | `"aurora-"` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | string | `"false"` | no |
| snapshot\_identifier | DB snapshot to create this database from | string | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | string | `"false"` | no |
| subnet\_ids | List of subnet IDs to use | list | n/a | yes |
| tags | A map of tags to add to all resources. | map | `<map>` | no |
| update\_timeout | Timeout used for Cluster modifications | string | `"120m"` | no |
| username | Master DB username | string | `"root"` | no |
| vpc\_id | VPC ID | string | n/a | yes |

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
