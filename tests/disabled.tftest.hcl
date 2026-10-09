
mock_provider "aws" {}

variables {
  enabled        = false
  domain_name    = "example.com"
  public_enabled = true
  record_enabled = true

  records = [
    {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.10"]
    }
  ]
}

run "disabled_module" {
  command = plan

  assert {
    condition     = output.zone_id == ""
    error_message = "Disabled module must not return a hosted zone ID."
  }

  assert {
    condition     = length(output.record_fqdns) == 0
    error_message = "Disabled module must not create DNS records."
  }
}
