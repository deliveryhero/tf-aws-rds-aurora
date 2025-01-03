provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

module "aurora" {
  source                          = "../../"
  name                            = "aurora-example-postgresql"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "16.4"
  subnet_ids                      = ["${module.vpc.database_subnets}"]
  vpc_id                          = "${module.vpc.vpc_id}"
  replica_count                   = 1
  instance_type                   = "db.serverless"
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_postgres164_parameter_group.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_postgres164_parameter_group.id}"
  serverlessv2_min_capacity       = 0.5
  serverlessv2_max_capacity       = 2
}

resource "aws_db_parameter_group" "aurora_db_postgres164_parameter_group" {
  name        = "test-aurora-db-postgres164-parameter-group"
  family      = "aurora-postgresql16.4"
  description = "test-aurora-db-postgres164-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres164_parameter_group" {
  name        = "test-aurora-postgres164-cluster-parameter-group"
  family      = "aurora-postgresql16.4"
  description = "test-aurora-postgres164-cluster-parameter-group"
}

resource "aws_security_group" "app_servers" {
  name        = "app-servers"
  description = "For application servers"
  vpc_id      = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = "${module.aurora.cluster_port}"
  to_port                  = "${module.aurora.cluster_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.app_servers.id}"
  security_group_id        = "${module.aurora.security_group_id}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.46.0"
  name    = "example-postgres"
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
