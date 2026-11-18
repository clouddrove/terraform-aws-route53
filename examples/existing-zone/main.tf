
## Managed By : CloudDrove

provider "aws" {
  region = "us-east-1"
}

module "route53" {
  source = "../.."

  name        = "route53"
  environment = "dev"
  managedby   = "terraform"

  label_order = [
    "environment",
    "name"
  ]

  enabled         = true
  public_enabled  = false
  private_enabled = false
  record_enabled  = true

  domain_name = "example.com"

  # Replace with your actual Route53 hosted-zone ID.
  zone_id = "Z0123456789ABCDEF"

  records = [
    {
      name    = "api"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.10"]
    },
    {
      name    = "www"
      type    = "CNAME"
      ttl     = 300
      records = ["example.com"]
    }
  ]

  force_destroy = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

output "zone_id" {
  value = module.route53.zone_id
}

output "record_fqdns" {
  value = module.route53.record_fqdns
}
