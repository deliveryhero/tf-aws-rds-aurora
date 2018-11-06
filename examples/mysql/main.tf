provider "aws" {
  region = "us-east-1"
}

variable "azs" {
  type = "list"

  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

module "aurora" {
  source                          = "../../"
  name                            = "aurora-example-mysql"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.12"
  subnet_ids                      = ["${module.vpc.database_subnets}"]
  availability_zones              = ["${var.azs}"]
  vpc_id                          = "${module.vpc.vpc_id}"
  replica_count                   = 1
  instance_type                   = "db.t2.medium"
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_57_parameter_group.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_57_cluster_parameter_group.id}"
}

resource "aws_db_parameter_group" "aurora_db_57_parameter_group" {
  name        = "test-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-db-57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_57_cluster_parameter_group" {
  name        = "test-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-57-cluster-parameter-group"
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
  name    = "example-mysql"
  cidr    = "10.0.0.0/16"
  azs     = ["${var.azs}"]

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
