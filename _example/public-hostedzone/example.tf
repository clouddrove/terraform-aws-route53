provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name           = "route53"
  environment    = "test"
  label_order    = ["environment", "name"]
  public_enabled = true
  record_enabled = false

  domain_name = "tech-tycoons.clouddrove.com"

  records = [
    {
      name = "www"
      type = "A"
      ttl  = 3600
      alias = {
        name    = "d130easdflja734js.cloudfront.net" # name of the attached service.
        zone_id = "Z2XXXXHXTXXXX4"
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
