## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

locals {
  ##----------------------------------------------------------------------------- 
  ##   Terragrunt users have to provide `records_jsonencoded` as jsonencode()'d string.
  ##   See details: https://github.com/gruntwork-io/terragrunt/issues/1211
  ##-----------------------------------------------------------------------------
  records = concat(var.records, try(jsondecode(var.records_jsonencoded), []))

  ##----------------------------------------------------------------------------- 
  ##   Convert `records` from list to map with unique keys
  ##-----------------------------------------------------------------------------
  recordsets = { for rs in local.records : try(rs.key, join(" ", compact(["${rs.name} ${rs.type}", try(rs.set_identifier, "")]))) => rs }
  zone_id    = var.enabled ? (var.zone_id != "" ? var.zone_id : (var.private_enabled ? aws_route53_zone.private[*].zone_id[0] : aws_route53_zone.public[*].zone_id[0])) : ""
}

##----------------------------------------------------------------------------- 
## Locals declration to determine count of public subnet, private subnet, and nat gateway. 
##-----------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository

}

##----------------------------------------------------------------------------- 
## Terraform module to create Route53 zone resource on AWS for creating private hosted zones. 
##-----------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
  count = var.enabled && var.private_enabled ? 1 : 0

  name          = var.domain_name
  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = module.labels.tags
  vpc {
    vpc_id = var.vpc_id
  }
}

##----------------------------------------------------------------------------- 
## Terraform module to create Route53 zone resource on AWS for creating public hosted zones. 
##-----------------------------------------------------------------------------
resource "aws_route53_zone" "public" {
  count = var.enabled && var.public_enabled ? 1 : 0

  name              = var.domain_name
  delegation_set_id = var.delegation_set_id
  comment           = var.comment
  force_destroy     = var.force_destroy
  tags              = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Terraform module to create Route53 record sets resource on AWS. 
##-----------------------------------------------------------------------------
resource "aws_route53_record" "this" {
  for_each = { for k, v in local.recordsets : k => v if var.enabled && var.record_enabled && (var.zone_id != null || var.public_enabled != null || var.private_enabled != null || var.domain_name != null) }

  zone_id = local.zone_id

  name                             = each.value.name != "" ? (lookup(each.value, "full_name_override", false) ? each.value.name : "${each.value.name}.${var.domain_name}") : var.domain_name
  type                             = each.value.type
  ttl                              = lookup(each.value, "ttl", null)
  records                          = try(each.value.records, null)
  set_identifier                   = lookup(each.value, "set_identifier", null)
  health_check_id                  = lookup(each.value, "health_check_id", null)
  multivalue_answer_routing_policy = lookup(each.value, "multivalue_answer_routing_policy", null)
  allow_overwrite                  = lookup(each.value, "allow_overwrite", false)

  dynamic "alias" {
    for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]

    content {
      name                   = each.value.alias.name
      zone_id                = try(each.value.alias.zone_id, local.zone_id)
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }

  dynamic "failover_routing_policy" {
    for_each = length(keys(lookup(each.value, "failover_routing_policy", {}))) == 0 ? [] : [true]

    content {
      type = each.value.failover_routing_policy.type
    }
  }

  dynamic "latency_routing_policy" {
    for_each = length(keys(lookup(each.value, "latency_routing_policy", {}))) == 0 ? [] : [true]

    content {
      region = each.value.latency_routing_policy.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = length(keys(lookup(each.value, "weighted_routing_policy", {}))) == 0 ? [] : [true]

    content {
      weight = each.value.weighted_routing_policy.weight
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = length(keys(lookup(each.value, "geolocation_routing_policy", {}))) == 0 ? [] : [true]

    content {
      continent   = lookup(each.value.geolocation_routing_policy, "continent", null)
      country     = lookup(each.value.geolocation_routing_policy, "country", null)
      subdivision = lookup(each.value.geolocation_routing_policy, "subdivision", null)
    }
  }
  depends_on = [
    aws_route53_zone.public,
    aws_route53_zone.private
  ]
}

##----------------------------------------------------------------------------- 
## Terraform module to create Route53 record sets resource on AWS for Weighted Routing Policy. 
##-----------------------------------------------------------------------------
resource "aws_route53_zone_association" "default" {
  count   = var.enabled && var.vpc_association_enabled && var.private_enabled ? 1 : 0
  zone_id = aws_route53_zone.private[*].zone_id[0]
  vpc_id  = var.secondary_vpc_id
}
