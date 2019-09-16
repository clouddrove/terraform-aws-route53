provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "./../"

  name        = "route53"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  private_enabled = true
  record_enabled = true

  domain_name        = "test.com"
  vpc_id = "vpc-039154442a5e28e94"

  type = "A"
  ttl = 30
  records = [
    "192.168.32.9",
  ]
}
