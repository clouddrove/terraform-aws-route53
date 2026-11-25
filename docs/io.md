## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comment | A comment for the hosted zone. Defaults to 'Managed by Terraform'. | `string` | `""` | no |
| delegation\_set\_id | The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones. | `string` | `""` | no |
| dnssec\_enabled | Whether to enable DNSSEC signing for the public hosted zone. Requires a Route 53 compatible KMS key ARN and key name. | `bool` | `false` | no |
| dnssec\_key\_name | Name for the Route 53 DNSSEC key-signing key. | `string` | `""` | no |
| dnssec\_kms\_key\_arn | ARN of a customer managed KMS key in `us-east-1` for DNSSEC signing. | `string` | `""` | no |
| domain\_name | This is the name of the resource. | `string` | n/a | yes |
| enabled | Flag to control the Route53 and related resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| force\_destroy | Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone. | `bool` | `true` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"anmol@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| private\_enabled | Whether to create private Route53 zone. | `bool` | `false` | no |
| public\_enabled | Whether to create public Route53 zone. | `bool` | `false` | no |
| record\_enabled | Whether to create Route53 record set. | `bool` | `false` | no |
| records | List of objects of DNS records | `any` | `[]` | no |
| records\_jsonencoded | List of map of DNS records (stored as jsonencoded string, for terragrunt) | `string` | `null` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-route53"` | no |
| secondary\_vpc\_id | The VPC to associate with the private hosted zone. | `string` | `""` | no |
| secondary\_vpc\_region | AWS Region of the additional VPC associated with the private hosted zone. Defaults to the configured AWS provider region. | `string` | `null` | no |
| vpc\_association\_enabled | Whether to create Route53 vpc association. | `bool` | `false` | no |
| vpc\_id | VPC ID. | `string` | `""` | no |
| vpc\_region | AWS Region of the VPC associated with the private hosted zone. Defaults to the configured AWS provider region. | `string` | `null` | no |
| zone\_id | Route53 Zone ID. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| tags | A mapping of tags to assign to the resource. |
| dnssec\_ds\_record | DS record to publish in the parent zone or at the registrar. Null when DNSSEC signing is disabled. |
| zone\_id | The Hosted Zone ID. This can be referenced by zone records. |
