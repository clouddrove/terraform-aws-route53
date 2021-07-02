provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name            = "route53"
  environment     = "test"
  label_order     = ["environment", "name"]
  private_enabled = true
  record_enabled  = true

  domain_name = "clouddrove.com"
  vpc_id      = "vpc-xxxxxxxxxxxx"

  names = [
    "www.",
    "admin."
  ]
  types = [
    "A",
    "CNAME"
  ]
  ttls = [
    "3600",
    "3600",
  ]
  values = [
    "10.0.0.27",
    "mydomain.com",
  ]
}
