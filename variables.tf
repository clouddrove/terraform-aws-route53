##----------------------------------------------------------------------------- 
## Locals declration to determine count of public subnet, private subnet, and nat gateway. 
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-route53"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

##----------------------------------------------------------------------------- 
## Terraform Route53 module variables.
##-----------------------------------------------------------------------------

variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the Route53 and related resources creation."
}

variable "record_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "private_enabled" {
  type        = bool
  default     = false
  description = "Whether to create private Route53 zone."
}

variable "public_enabled" {
  type        = bool
  default     = false
  description = "Whether to create public Route53 zone."
}

variable "records" {
  description = "List of objects of DNS records"
  type        = any
  default     = []
}

variable "records_jsonencoded" {
  description = "List of map of DNS records (stored as jsonencoded string, for terragrunt)"
  type        = string
  default     = null
}

variable "domain_name" {
  type        = string
  description = "This is the name of the resource."
}

variable "comment" {
  type        = string
  default     = ""
  description = "A comment for the hosted zone. Defaults to 'Managed by Terraform'."
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone."
}

variable "delegation_set_id" {
  type        = string
  default     = ""
  description = "The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID."
}

variable "vpc_association_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 vpc association."
}

variable "secondary_vpc_id" {
  type        = string
  default     = ""
  description = "The VPC to associate with the private hosted zone."
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 Zone ID."
}