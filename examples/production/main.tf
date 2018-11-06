provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

module "aurora" {
  source                          = "../../"
  name                            = "aurora-example-production"
  engine                          = "aurora-postgresql"
  engine_version                  = "9.6.3"
  subnet_ids                      = ["${module.vpc1.database_subnets}"]
  availability_zones              = ["${data.aws_availability_zones.available.names}"]
  vpc_id                          = "${module.vpc1.vpc_id}"
  replica_count                   = 2
  replica_autoscaling             = true
  replica_scale_min               = 2
  replica_scale_max               = 5
  monitoring_interval             = 60
  instance_type                   = "db.r4.large"
  allowed_security_groups         = ["${aws_security_group.my-app.id}"]
  cloudwatch_alarm_actions        = ["${aws_sns_topic.my-app-monitoring.arn}"]
  cloudwatch_create_alarms        = true
  route53_zone_id                 = "${aws_route53_zone.vpc_internal_zone.id}"
  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_postgres96_parameter_group.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_postgres96_parameter_group.id}"

  tags = {
    app         = "my-app"
    environment = "production"
  }
}

resource "aws_db_parameter_group" "aurora_db_postgres96_parameter_group" {
  name        = "example-production-postgres96"
  family      = "aurora-postgresql9.6"
  description = "For example aurora-example-production"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres96_parameter_group" {
  name        = "example-production-postgres96"
  family      = "aurora-postgresql9.6"
  description = "For example aurora-example-production"
}

resource "aws_security_group" "app_servers" {
  name        = "app-servers"
  description = "For application servers"
  vpc_id      = "${module.vpc1.vpc_id}"
}

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.46.0"
  name    = "example-production"
  cidr    = "10.0.0.0/16"
  azs     = ["${data.aws_availability_zones.available.names}"]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/25",
  ]

  public_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/25",
  ]

  database_subnets = [
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/25",
  ]
}

# An internal zone to use in VPC
resource "aws_route53_zone" "vpc_internal_zone" {
  name    = "local.vpc"
  comment = "VPC internal zone for aurora-example"

  vpc {
    vpc_id = "${module.vpc1.vpc_id}"
  }
}

# A security group for my-app ec2 instances
resource "aws_security_group" "my-app" {
  name        = "my-app"
  description = "For application my-app"
  vpc_id      = "${module.vpc1.vpc_id}"

  tags = {
    app         = "my-app"
    environment = "production"
  }
}

# An SNS topic for cloudwatch alarm actions. Can be connected to Slack, or email etc
resource "aws_sns_topic" "my-app-monitoring" {
  name = "my-app-monitoring"
}
