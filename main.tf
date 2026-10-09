
## Managed By : CloudDrove
## Copyright @ CloudDrove. All Rights Reserved.

##-----------------------------------------------------------------------------
## Local Variables
##-----------------------------------------------------------------------------
locals {
  ##---------------------------------------------------------------------------
  ## Support Terraform and Terragrunt DNS record inputs.
  ##---------------------------------------------------------------------------

  records = concat(
    var.records,
    try(jsondecode(var.records_jsonencoded), [])
  )

  ##---------------------------------------------------------------------------
  ## Convert DNS records into a map with unique keys.
  ##---------------------------------------------------------------------------

  recordsets = {
    for rs in local.records :
    try(
      rs.key,
      join(" ", compact([
        "${rs.name} ${rs.type}",
        try(rs.set_identifier, "")
      ]))
    ) => rs
  }

  ##---------------------------------------------------------------------------
  ## Determine the effective Route53 hosted zone ID.
  ##
  ## Priority:
  ## 1. Existing hosted zone supplied through zone_id
  ## 2. Newly created private hosted zone
  ## 3. Newly created public hosted zone
  ##---------------------------------------------------------------------------

  zone_id = !var.enabled ? "" : (
    var.zone_id != "" ? var.zone_id :
    var.private_enabled ? try(aws_route53_zone.private[0].zone_id, "") :
    var.public_enabled ? try(aws_route53_zone.public[0].zone_id, "") :
    ""
  )
}

##-----------------------------------------------------------------------------
## CloudDrove Labels Module
##-----------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.1"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
  extra_tags  = var.tags
}

##-----------------------------------------------------------------------------
## Private Route53 Hosted Zone
##-----------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
  count = var.enabled && var.private_enabled ? 1 : 0

  name          = var.domain_name
  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = module.labels.tags

  ##---------------------------------------------------------------------------
  ## Associate primary VPC with private hosted zone.
  ##---------------------------------------------------------------------------

  vpc {
    vpc_id     = var.vpc_id
    vpc_region = var.vpc_region
  }

  lifecycle {
    ## Validate primary VPC ID.
    precondition {
      condition     = var.vpc_id != ""
      error_message = "vpc_id must be provided when private_enabled is true."
    }

    ## Prevent public and private zones from being created together.
    precondition {
      condition     = !var.public_enabled
      error_message = "public_enabled and private_enabled cannot both be true."
    }

    ## Prevent zone creation when an existing zone_id is supplied.
    precondition {
      condition     = var.zone_id == ""
      error_message = "Do not provide zone_id when creating a private hosted zone."
    }
  }
}

##-----------------------------------------------------------------------------
## Public Route53 Hosted Zone
##-----------------------------------------------------------------------------
resource "aws_route53_zone" "public" {
  count = var.enabled && var.public_enabled ? 1 : 0

  name = var.domain_name

  delegation_set_id = (
    var.delegation_set_id != "" ? var.delegation_set_id : null
  )

  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = module.labels.tags

  lifecycle {
    ## Prevent public and private zones from being created together.
    precondition {
      condition     = !var.private_enabled
      error_message = "public_enabled and private_enabled cannot both be true."
    }

    ## Prevent creating a new zone when an existing zone ID is supplied.
    precondition {
      condition     = var.zone_id == ""
      error_message = "Do not provide zone_id when creating a public hosted zone."
    }
  }
}

##-----------------------------------------------------------------------------
## Route53 DNS Records
##
## Supported record configurations:
## - Standard DNS records
## - Alias records
## - Weighted routing
## - Latency routing
## - Failover routing
## - Geolocation routing
## - Multivalue answer routing
##-----------------------------------------------------------------------------
resource "aws_route53_record" "this" {

  ##---------------------------------------------------------------------------
  ## Create DNS records only when the module and records are enabled.
  ##---------------------------------------------------------------------------

  for_each = (
    var.enabled && var.record_enabled
    ? local.recordsets
    : {}
  )

  zone_id = local.zone_id

  ##---------------------------------------------------------------------------
  ## Record name configuration.
  ## Supports relative names and full_name_override.
  ##---------------------------------------------------------------------------

  name = each.value.name != "" ? (
    lookup(each.value, "full_name_override", false)
    ? each.value.name
    : "${each.value.name}.${var.domain_name}"
  ) : var.domain_name

  type = each.value.type

  ##---------------------------------------------------------------------------
  ## Standard DNS record attributes.
  ##---------------------------------------------------------------------------

  ttl     = lookup(each.value, "ttl", null)
  records = try(each.value.records, null)

  set_identifier = lookup(
    each.value,
    "set_identifier",
    null
  )

  health_check_id = lookup(
    each.value,
    "health_check_id",
    null
  )

  multivalue_answer_routing_policy = lookup(
    each.value,
    "multivalue_answer_routing_policy",
    null
  )

  allow_overwrite = lookup(
    each.value,
    "allow_overwrite",
    false
  )

  ##---------------------------------------------------------------------------
  ## Alias Records
  ##
  ## The target hosted zone ID must be supplied explicitly.
  ## Examples include ALB, NLB, CloudFront or another Route53 record.
  ##---------------------------------------------------------------------------

  dynamic "alias" {
    for_each = try(each.value.alias, null) == null ? (
      []
    ) : [each.value.alias]

    content {
      name    = alias.value.name
      zone_id = alias.value.zone_id

      evaluate_target_health = lookup(
        alias.value,
        "evaluate_target_health",
        false
      )
    }
  }

  ##---------------------------------------------------------------------------
  ## Failover Routing Policy
  ##---------------------------------------------------------------------------

  dynamic "failover_routing_policy" {
    for_each = try(each.value.failover_routing_policy, null) == null ? (
      []
    ) : [each.value.failover_routing_policy]

    content {
      type = failover_routing_policy.value.type
    }
  }

  ##---------------------------------------------------------------------------
  ## Latency Routing Policy
  ##---------------------------------------------------------------------------

  dynamic "latency_routing_policy" {
    for_each = try(each.value.latency_routing_policy, null) == null ? (
      []
    ) : [each.value.latency_routing_policy]

    content {
      region = latency_routing_policy.value.region
    }
  }

  ##---------------------------------------------------------------------------
  ## Weighted Routing Policy
  ##---------------------------------------------------------------------------

  dynamic "weighted_routing_policy" {
    for_each = try(each.value.weighted_routing_policy, null) == null ? (
      []
    ) : [each.value.weighted_routing_policy]

    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  ##---------------------------------------------------------------------------
  ## Geolocation Routing Policy
  ##---------------------------------------------------------------------------

  dynamic "geolocation_routing_policy" {
    for_each = try(each.value.geolocation_routing_policy, null) == null ? (
      []
    ) : [each.value.geolocation_routing_policy]

    content {
      continent = lookup(
        geolocation_routing_policy.value,
        "continent",
        null
      )

      country = lookup(
        geolocation_routing_policy.value,
        "country",
        null
      )

      subdivision = lookup(
        geolocation_routing_policy.value,
        "subdivision",
        null
      )
    }
  }

  ##---------------------------------------------------------------------------
  ## Resource Preconditions
  ##---------------------------------------------------------------------------

  lifecycle {
    ## Validate hosted zone availability.
    precondition {
      condition     = local.zone_id != ""
      error_message = "Provide an existing zone_id or enable public_enabled/private_enabled."
    }

    ## Prevent simultaneous alias and standard DNS values.
    precondition {
      condition = !(
        try(each.value.alias, null) != null &&
        try(each.value.records, null) != null
      )

      error_message = "A DNS record cannot contain both alias and records."
    }

    ## Ensure alias target zone ID exists.
    precondition {
      condition = (
        try(each.value.alias, null) == null ||
        try(length(trimspace(each.value.alias.zone_id)) > 0, false)
      )

      error_message = "Alias record must specify a valid target zone_id."
    }
  }

  ##---------------------------------------------------------------------------
  ## Ensure hosted zones are processed before DNS records.
  ##---------------------------------------------------------------------------

  depends_on = [
    aws_route53_zone.public,
    aws_route53_zone.private
  ]
}

##-----------------------------------------------------------------------------
## Additional VPC Association for Private Hosted Zone
##-----------------------------------------------------------------------------
resource "aws_route53_zone_association" "default" {

  count = (
    var.enabled &&
    var.vpc_association_enabled &&
    var.private_enabled
  ) ? 1 : 0

  zone_id = aws_route53_zone.private[0].zone_id

  vpc_id     = var.secondary_vpc_id
  vpc_region = var.secondary_vpc_region

  lifecycle {
    ## Validate secondary VPC.
    precondition {
      condition     = var.secondary_vpc_id != ""
      error_message = "secondary_vpc_id must be provided when vpc_association_enabled is true."
    }

    ## Prevent associating the primary VPC again.
    precondition {
      condition = !(
        var.secondary_vpc_id == var.vpc_id &&
        coalesce(var.secondary_vpc_region, "") == coalesce(var.vpc_region, "")
      )

      error_message = "Secondary VPC association must be different from the primary VPC association."
    }
  }
}
