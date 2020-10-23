## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.13.0"

  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

# Module      : Route53
# Description : Terraform module to create Route53 zone resource on AWS for creating private
#               hosted zones.
resource "aws_route53_zone" "private" {
  count = var.private_enabled ? 1 : 0

  name          = var.domain_name
  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = module.labels.tags
  vpc {
    vpc_id = var.vpc_id
  }
}

# Module      : Route53
# Description : Terraform module to create Route53 zone resource on AWS for creating public
#               hosted zones.
resource "aws_route53_zone" "public" {
  count = var.public_enabled ? 1 : 0

  name              = var.domain_name
  delegation_set_id = var.delegation_set_id
  comment           = var.comment
  force_destroy     = var.force_destroy
  tags              = module.labels.tags
}

# Module      : Route53 Record Set
# Description : Terraform module to create Route53 record sets resource on AWS.
resource "aws_route53_record" "default" {
  count                            = var.record_enabled && length(var.ttls) > 0 ? length(var.ttls) : 0
  zone_id                          = var.zone_id != "" ? var.zone_id : (var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : aws_route53_zone.public.*.zone_id[0])
  name                             = element(var.names, count.index)
  type                             = element(var.types, count.index)
  ttl                              = element(var.ttls, count.index)
  records                          = split(",", element(var.values, count.index))
  set_identifier                   = length(var.set_identifiers) > 0 ? element(var.set_identifiers, count.index) : ""
  health_check_id                  = length(var.health_check_ids) > 0 ? element(var.health_check_ids, count.index) : ""
  multivalue_answer_routing_policy = length(var.multivalue_answer_routing_policies) > 0 ? element(var.multivalue_answer_routing_policies, count.index) : null
  allow_overwrite                  = length(var.allow_overwrites) > 0 ? element(var.allow_overwrites, count.index) : false
}

# Module      : Route53 Record Set
# Description : Terraform module to create Route53 record sets resource on AWS.
resource "aws_route53_record" "alias" {
  count                            = var.record_enabled && length(var.alias) > 0 && length(var.alias["names"]) > 0 ? length(var.alias["names"]) : 0
  zone_id                          = var.zone_id
  name                             = element(var.names, count.index)
  type                             = element(var.types, count.index)
  set_identifier                   = length(var.set_identifiers) > 0 ? element(var.set_identifiers, count.index) : ""
  health_check_id                  = length(var.health_check_ids) > 0 ? element(var.health_check_ids, count.index) : ""
  multivalue_answer_routing_policy = length(var.multivalue_answer_routing_policies) > 0 ? element(var.multivalue_answer_routing_policies, count.index) : null
  allow_overwrite                  = length(var.allow_overwrites) > 0 ? element(var.allow_overwrites, count.index) : false
  alias {
    name                   = length(var.alias) > 0 ? element(var.alias["names"], count.index) : ""
    zone_id                = length(var.alias) > 0 ? element(var.alias["zone_ids"], count.index) : ""
    evaluate_target_health = length(var.alias) > 0 ? element(var.alias["evaluate_target_healths"], count.index) : false
  }
}

# Module      : Route53
# Description : Terraform module to create Route53 record sets resource on AWS for Weighted
#               Routing Policy.
resource "aws_route53_zone_association" "default" {
  count   = var.enabled ? 1 : 0
  zone_id = var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : aws_route53_zone.public.*.zone_id[0]
  vpc_id  = var.secondary_vpc_id
}
