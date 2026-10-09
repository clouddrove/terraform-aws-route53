
mock_provider "aws" {}

variables {
  enabled        = true
  domain_name    = "example.com"
  zone_id        = "Z0123456789ABCDEF"
  public_enabled = false
  private_enabled = false
  record_enabled = true

  records = [
    {
      name    = "api"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.10"]
    }
  ]
}

run "existing_zone" {
  command = plan

  assert {
    condition     = output.zone_id == "Z0123456789ABCDEF"
    error_message = "The existing hosted-zone ID should be returned."
  }

  assert {
    condition     = length(aws_route53_zone.public) == 0
    error_message = "No public hosted zone should be created."
  }

  assert {
    condition     = length(aws_route53_zone.private) == 0
    error_message = "No private hosted zone should be created."
  }

  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "Exactly one DNS record should be planned."
  }
}
