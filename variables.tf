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
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
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

  validation {
    condition     = !var.record_enabled || var.zone_id != "" || var.private_enabled || var.public_enabled
    error_message = "record_enabled requires zone_id or a hosted zone enabled by this module."
  }
}

variable "private_enabled" {
  type        = bool
  default     = false
  description = "Whether to create private Route53 zone."

  validation {
    condition     = !var.private_enabled || var.vpc_id != ""
    error_message = "vpc_id must be set when private_enabled is true."
  }
}

variable "public_enabled" {
  type        = bool
  default     = false
  description = "Whether to create public Route53 zone."

  validation {
    condition     = !(var.private_enabled && var.public_enabled)
    error_message = "Choose either private_enabled or public_enabled; a single module instance cannot create both zone types."
  }
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

variable "dnssec_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable DNSSEC signing for the public hosted zone. Supply a Route 53 compatible KMS key ARN and coordinate the DS record with the parent zone or registrar."

  validation {
    condition     = !var.dnssec_enabled || (!var.private_enabled && (var.public_enabled || var.zone_id != ""))
    error_message = "dnssec_enabled requires a public hosted zone created by this module or a public zone_id, and cannot be used with private_enabled."
  }
}

variable "dnssec_kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of the customer managed KMS key used by the Route 53 DNSSEC key-signing key. The KMS key must be in us-east-1 and meet Route 53 DNSSEC requirements."

  validation {
    condition     = !var.dnssec_enabled || var.dnssec_kms_key_arn != ""
    error_message = "dnssec_kms_key_arn must be set when dnssec_enabled is true."
  }
}

variable "dnssec_key_name" {
  type        = string
  default     = ""
  description = "Name for the Route 53 DNSSEC key-signing key."

  validation {
    condition     = !var.dnssec_enabled || var.dnssec_key_name != ""
    error_message = "dnssec_key_name must be set when dnssec_enabled is true."
  }
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

variable "vpc_region" {
  type        = string
  default     = null
  description = "AWS Region of the VPC associated with the private hosted zone. Defaults to the configured AWS provider region."
}

variable "vpc_association_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 vpc association."

  validation {
    condition     = !var.vpc_association_enabled || (var.private_enabled && var.secondary_vpc_id != "")
    error_message = "vpc_association_enabled requires private_enabled and a non-empty secondary_vpc_id."
  }
}

variable "secondary_vpc_id" {
  type        = string
  default     = ""
  description = "The VPC to associate with the private hosted zone."
}

variable "secondary_vpc_region" {
  type        = string
  default     = null
  description = "AWS Region of the additional VPC associated with the private hosted zone. Defaults to the configured AWS provider region."
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 Zone ID."
}
