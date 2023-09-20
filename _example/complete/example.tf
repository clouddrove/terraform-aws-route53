provider "aws" {
  region = "eu-west-1"
}

module "route53" {
  source = "../../"

  name            = "route53"
  environment     = "test"
  label_order     = ["environment", "name"]
  public_enabled  = true
  record_enabled  = true

  domain_name = "clouddrove.com"
  
  records = [
    {
      name = ""
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
    },
    {
      name           = "geo"
      type           = "CNAME"
      ttl            = 5
      records        = ["europe.test.clouddrove.com."]
      set_identifier = "europe"
      geolocation_routing_policy = {
        continent = "EU"
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test.clouddrove.com."]
      set_identifier = "test-primary"
      weighted_routing_policy = {
        weight = 90
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test.clouddrove.com."]
      set_identifier = "test-secondary"
      weighted_routing_policy = {
        weight = 10
      }
    }
  ]
}
