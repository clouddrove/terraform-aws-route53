provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "./../../"

  name        = "route53"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  private_enabled = true
  enabled = true

  domain_name        = "clouddrove.com"
  vpc_id = "vpc-06e06f3f2f14d9946"

  secondary_vpc_id = "vpc-0878136fa520c810c"
  secondary_vpc_region = "eu-west-1"
}
