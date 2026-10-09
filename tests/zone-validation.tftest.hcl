
mock_provider "aws" {}

variables {
  enabled         = true
  domain_name     = "example.com"
  public_enabled  = true
  private_enabled = true

  vpc_id = "vpc-0123456789abcdef0"
}

run "reject_both_zone_types" {
  command = plan

  expect_failures = [
    aws_route53_zone.public[0],
    aws_route53_zone.private[0]
  ]
}
