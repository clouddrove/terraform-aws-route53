provider "aws" {
  region = "ca-central-1"
}

locals {
  zone_id = "Z08XXXXXXQJXXCJCXXXX" # Route53 Zone ID
}

module "route53" {
  source = "../../"

  name           = "route53"
  environment    = "test"
  label_order    = ["environment", "name"]
  public_enabled = false
  record_enabled = true

  zone_id     = local.zone_id
  domain_name = "clouddrove.com"

  records = [
    {
      name = ""
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
    },
    {
      name           = "geo"
      type           = "CNAME"
      ttl            = 5
      records        = ["europe.test.clouddrove.com."]
      set_identifier = "europe"
      geolocation_routing_policy = {
        continent = "EU"
      }
    },
    {
      name           = "proximity"
      type           = "A"
      set_identifier = "canada"
      records        = ["192.0.2.20"]
      ttl            = 300
      geoproximity_routing_policy = {
        aws_region = "ca-central-1"
        bias       = 0
      }
    },
    {
      name           = "ip-routed"
      type           = "A"
      set_identifier = "canada-cidrs"
      records        = ["192.0.2.30"]
      ttl            = 300
      cidr_routing_policy = {
        collection_id = "C1A2B3C4D5E6F7" # Replace with an existing Route 53 CIDR collection ID.
        location_name = "canada"         # Replace with a location in that collection.
      }
    },
    {
      name = "alias-1"
      type = "A"
      alias = {
        name    = "CHANGEME001" # name of the attached service.
        zone_id = local.zone_id
      }
    },
    {
      name           = "weighted-policy-test-2"
      type           = "A"
      set_identifier = "test-1"
      alias = {
        name    = "dummy-alb-111111.us-east-1.elb.amazonaws.com"
        zone_id = "Z11SXDOTRQ7X7K"
      }
      weighted_routing_policy = {
        weight = 50
      }
    },
    {
      name           = "weighted"
      type           = "A"
      set_identifier = "test-2"
      alias = {
        name    = "dummy-alb-222222.us-east-1.elb.amazonaws.com"
        zone_id = "Z225XDOTRQ7X7K"
      }
      weighted_routing_policy = {
        weight = 50
      }
    }
  ]
}
