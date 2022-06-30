# tf-aws-kms-key
 
Terraform module to provision a [KMS](https://aws.amazon.com/kms/) key with alias.

## Usage

```hcl
module "kms_key" {
  description             = "KMS key for chamber"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"
  alias                   = "alias/some_kms_key_alias"
  tags                    = "owner:someone"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alias | The display name of the alias. The name must start with the word `alias` followed by a forward slash | string | `` | no |
| deletion_window_in_days | Duration in days after which the key is deleted after destruction of the resource | string | `10` | no |
| description | The description of the key as viewed in AWS console | string | `Parameter Store KMS master key` | no |
| enable_key_rotation | Specifies whether key rotation is enabled | string | `true` | no |
| enable_key_rotation | IAM policy JSON document to be applied to the KMS key | string | `` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| alias_arn | Alias ARN |
| alias_name | Alias name |
| key_arn | Key ARN |
| key_id | Key ID |
