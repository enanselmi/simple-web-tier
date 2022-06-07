# If the running Terraform version doesn't meet these constraints,
# an error is shown
# terraform {
#   required_version = "0.14.4"

# Uncomment this and replace it with your configuration to enable
# the Terraform S3 backend configuration. Remember that the module
# `tf-aws-tfstate-s3-dynamodb` would take care of the provisioning of
# the necessary resources.
#backend "s3" {
#  region         = "us-east-1"
#  bucket         = "terraform-template-dev-tfstate"
#  key            = "development/terraform.tfstate"
#  dynamodb_table = "terraform-template-dev-tfstate-lock"
#}
# }
