provider "aws" {
  region = var.region.default
  default_tags {
    tags = merge(
      var.default_tags,
      {
        backup = true
      }
    )
  }
}
terraform {
  required_version = "1.1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

