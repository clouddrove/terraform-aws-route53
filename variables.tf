#Module      : LABEL
#Description : Terraform label module variables
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

# Module      : Route53
# Description : Terraform Route53 module variables.
variable "private_enabled" {
  type        = bool
  default     = false
  description = "Whether to create private Route53 zone."
}

variable "record_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "public_enabled" {
  type        = bool
  default     = false
  description = "Whether to create public Route53 zone."
}

variable "record_set_enabled" {
  type        = bool
  default     = false
  description = "Whether to create seperate Route53 record set."
}

variable "failover_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "latency_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "geolocation_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "weighted_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
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

variable "types" {
  type        = list
  default     = []
  description = "The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. "
}

variable "ttls" {
  type        = list
  default     = []
  description = "(Required for non-alias records) The TTL of the record."
}

variable "names" {
  type        = list
  default     = []
  description = "The name of the record."
}

variable "values" {
  type        = list
  default     = []
  description = "(Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string (e.g. \"first255characters\"\"morecharacters\")."
}

variable "set_identifiers" {
  type        = list
  default     = []
  description = "Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, or weighted routing policies documented below."
}

variable "health_check_ids" {
  type        = list
  default     = []
  description = "The health check the record should be associated with."
}

variable "alias" {
  type        = map
  default     = {}
  description = "An alias block. Conflicts with ttl & records. Alias record documented below."
}

variable "failover_routing_policies" {
  default     = null
  description = "A block indicating the routing behavior when associated health check fails. Conflicts with any other routing policy. Documented below."
}

variable "geolocation_routing_policies" {
  default     = null
  description = "A block indicating a routing policy based on the geolocation of the requestor. Conflicts with any other routing policy. Documented below."
}

variable "latency_routing_policies" {
  default     = null
  description = "A block indicating a routing policy based on the latency between the requestor and an AWS region. Conflicts with any other routing policy. Documented below."
}

variable "weighted_routing_policies" {
  default     = null
  description = "A block indicating a weighted routing policy. Conflicts with any other routing policy. Documented below."
}

variable "multivalue_answer_routing_policies" {
  type        = list
  default     = []
  description = "Set to true to indicate a multivalue answer routing policy. Conflicts with any other routing policy."
}

variable "allow_overwrites" {
  type        = list
  default     = []
  description = "Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. false by default. This configuration is not recommended for most environments."
}

variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 vpc association."
}

variable "secondary_vpc_id" {
  type        = string
  default     = ""
  description = "The VPC to associate with the private hosted zone."
}

variable "secondary_vpc_region" {
  type        = string
  default     = ""
  description = "The VPC's region. Defaults to the region of the AWS provider."
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Zone ID."
}