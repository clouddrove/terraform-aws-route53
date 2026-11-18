
mock_provider "aws" {}

## Records with different shapes (standard, alias, routing policy) must plan.
variables {
  enabled        = true
  domain_name    = "example.com"
  zone_id        = "Z0123456789ABCDEF"
  record_enabled = true

  records = [
    {
      name    = "api"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.10"]
    },
    {
      name = "cdn"
      type = "A"
      alias = {
        name    = "d111111abcdef8.cloudfront.net"
        zone_id = "Z2FDTNDATAQYW2"
      }
    },
    {
      name           = "weighted"
      type           = "A"
      set_identifier = "blue"
      alias = {
        name = "api.example.com"
      }
      weighted_routing_policy = {
        weight = 50
      }
    }
  ]
}

run "mixed_record_shapes" {
  command = plan

  assert {
    condition     = length(aws_route53_record.this) == 3
    error_message = "All three heterogeneous records should be planned."
  }

  assert {
    condition     = one(aws_route53_record.this["weighted A blue"].alias).zone_id == "Z0123456789ABCDEF"
    error_message = "Alias without zone_id should fall back to the module zone."
  }
}

run "mixed_records_disabled" {
  command = plan

  variables {
    record_enabled = false
  }

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "No records should be planned when record_enabled is false."
  }
}
