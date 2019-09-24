# Module      : Route53
# Description : Terraform module to create Route53 resource on AWS for managing queue.
output "zone_id" {
  value       = var.zone_id != "" ? "" : (var.public_enabled ? join("", aws_route53_zone.public.*.zone_id) : join("", aws_route53_zone.private.*.zone_id))
  description = "The Hosted Zone ID. This can be referenced by zone records."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}