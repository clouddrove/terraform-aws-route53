# Module      : Route53
# Description : Terraform module to create Route53 resource on AWS for managing queue.
output "zone_id" {
  value = concat(
    aws_route53_zone.private.*.zone_id,
    aws_route53_zone.public.*.zone_id,
  )[0]
  description = "The Hosted Zone ID. This can be referenced by zone records."
}