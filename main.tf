## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git"

  name        = var.name
  application = var.application
  environment = var.environment
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
  count                            = var.record_enabled ? 1 : 0
  zone_id                          = var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : aws_route53_zone.public.*.zone_id[0]
  name                             = var.domain_name
  type                             = var.type
  ttl                              = var.ttl
  records                          = var.records
  set_identifier                   = var.set_identifier
  health_check_id                  = var.health_check_id
  multivalue_answer_routing_policy = var.multivalue_answer_routing_policy
  allow_overwrite                  = var.allow_overwrite
}

# Module      : Route53
# Description : Terraform module to create Route53 record sets resource on AWS for Weighted
#               Routing Policy.
resource "aws_route53_zone_association" "default" {
  count   = var.enabled ? 1 : 0
  zone_id = var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : aws_route53_zone.public.*.zone_id[0]
  vpc_id  = var.secondary_vpc_id
}