##-----------------------------------------------------------------------------
## Terraform module to create Route53 resource on AWS for managing queue.
##-----------------------------------------------------------------------------
output "zone_id" {
  value       = var.zone_id != "" ? "" : (var.public_enabled ? join("", aws_route53_zone.public[*].zone_id) : join("", aws_route53_zone.private[*].zone_id))
  description = "The Hosted Zone ID. This can be referenced by zone records."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}

output "dnssec_ds_record" {
  value       = try(aws_route53_key_signing_key.this[0].ds_record, null)
  description = "The DS record to publish in the parent zone or at the domain registrar to establish the DNSSEC chain of trust. Null when DNSSEC signing is disabled."
}
