provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name           = "route53"
  environment    = "test"
  label_order    = ["environment", "name"]
  public_enabled = true
  record_enabled = true

  domain_name = "clouddrove.com"

  records = [
    {
      name = "www"
      type = "A"
      alias = {
        name    = "d130easdflja734js.cloudfront.net" # name/DNS of attached cloudfront.
        zone_id = "Z2XXXXHXTXXXX4" # A valid zone ID of cloudfront you are trying to create alias of.
      }
    },
    {
      name    = "admin"
      type    = "CNAME"
      ttl     = 3600
      records = ["d130easdflja734js.cloudfront.net"]
    },
  ]
}
