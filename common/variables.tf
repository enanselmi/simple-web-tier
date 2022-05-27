variable "vpc_cidr" {  
    type     = any
    description = "VPC CIDr"
    default = []
}

variable "public_subnets" {
    description = "List of public subnets"
    type    = any  
    default = []

}

variable "private_subnets" {
  description = "List of private subnets"
  type     = any
  default = []

}

variable "azs" {
  description = "List of AZs"
  type     = any
  default = []

}

variable "region" {  
  type     = any
  description = "Region where to deploy"
  default = []
}

variable "default_tags" {
  description = "List of default tags"
  type     = any
  default = {
      owner          = "eanselmi@edrans.com"
      Name           = "Test For CNB"
      environment    = "tst"
      costCenter     = "SYSENG"
      tagVersion     = 1
      role           = "tst"
      project        = "CNB"
      expirationDate = "12/12/2022"
    }
}
