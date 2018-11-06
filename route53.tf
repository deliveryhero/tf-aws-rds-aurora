resource "aws_route53_record" "default" {
  count   = "${var.create_resources ? var.route53_zone_id == "" ? 0 : 1 : 0}"
  zone_id = "${var.route53_zone_id}"
  name    = "${aws_rds_cluster.main.id}${var.route53_record_appendix}"
  type    = "CNAME"
  ttl     = "${var.route53_record_ttl}"
  records = ["${aws_rds_cluster.main.endpoint}"]
}
