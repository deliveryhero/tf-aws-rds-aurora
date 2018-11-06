# Production ready example

This example will provide:

- A multi-AZ cluster
- Autoscaling of read replicas
- Enhanced monitoring enabled
- Cloudwatch alarms enabled
- An SNS topic for cloudwatch alarm monitoring that could be connected to Slack, or email etc
- An internal Route53 zone to avoid using default long AWS endpoints
- Descriptive tags

To apply:

```shell
terraform init

# Work around for "value of 'count' cannot be computed" error/bug
terraform apply -target=aws_route53_zone.vpc_internal_zone -target=aws_security_group.my-app

# Now apply to all resources
terraform apply
```
