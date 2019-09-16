provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "./../../"

  name        = "route53"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  public_enabled = true
  record_enabled = true

  domain_name        = "clouddrove.com"

  type = "A"
  ttl = 30
  records = ["10.0.0.27"]
}
