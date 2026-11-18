mock_provider "aws" {}

variables {
  domain_name = "example.com"
  enabled     = false
}

run "validate_module" {
  command = plan
}
