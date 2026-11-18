provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  enabled         = true
  name            = "route53"
  environment     = "test"
  label_order     = ["environment", "name"]
  private_enabled = true
  record_enabled  = false

  domain_name = "clouddrove.com"
  vpc_id      = "vpc-xxxxxxxxxxxxxx"

  vpc_association_enabled = true
  secondary_vpc_id        = "vpc-yyyyyyyyyyyyyy" # Must differ from vpc_id (or use a different secondary_vpc_region)
}
