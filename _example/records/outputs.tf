output "id" {
  value       = module.route53.*.zone_id
  description = "The ID of the Hostzone."
}

output "tags" {
  value       = module.route53.tags
  description = "A mapping of tags to assign to the resource."
}