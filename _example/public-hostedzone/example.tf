provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name           = "route53"
  application    = "clouddrove"
  environment    = "test"
  label_order    = ["environment", "name", "application"]
  public_enabled = true
  record_enabled = true

  domain_name = "clouddrove.com"

  names = [
    "www.",
    "admin."
  ]
  types = [
    "A",
    "CNAME"
  ]
  alias = {
    names = [
      "d130easdflja734js.cloudfront.net"
    ]
    zone_ids = [
      "Z2FDRFHATA1ER4"
    ]
    evaluate_target_healths = [
      false
    ]
  }
}
