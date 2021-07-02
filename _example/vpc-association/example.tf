provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name            = "route53"
  environment     = "test"
  label_order     = ["environment", "name"]
  private_enabled = true
  enabled         = true

  domain_name = "clouddrove.com"
  vpc_id      = "vpc-xxxxxxxxxxxxxx"

  secondary_vpc_id     = "vpc-xxxxxxxxxxxxxx"
  secondary_vpc_region = "eu-west-1"
}
