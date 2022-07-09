variable "vpc" {
  description = "VPC Variables"
  type        = any

}

variable "public_subnets" {
  description = "List of public subnets"
  type        = any
  default     = []

}

variable "private_subnets" {
  description = "List of private subnets"
  type        = any
  default     = []

}

variable "azs" {
  description = "List of AZs"
  type        = any
  default     = []

}

variable "region" {
  type        = any
  description = "Region where to deploy"
  default     = []
}

variable "default_tags" {
  description = "List of default tags"
  type        = any
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

variable "alb" {
  description = "List of variables fot ALB"
  type        = any
}

variable "alb_target_group" {
  description = "List of variables fot ALB target group"
  type        = any
}

variable "cnb_public_alb_listener_http" {
  description = "List of variables fot ALB http listener"
  type        = any
}

variable "cnb_public_alb_listener_https" {
  description = "List of variables fot ALB https listener"
  type        = any
}

variable "cnb_cert" {
  description = "List of variables fot ACM certificate"
  type        = any
}

variable "cnb_public_alb_sg" {
  description = "List of variables fot ALB"
  type        = any
}

variable "asg_tags" {
  description = "List of tags variables fot ASG"
  type        = any
}

variable "launch_configuration" {
  description = "List of launch configuration variables"
  type        = any
}

variable "asg" {
  description = "List of ASG variables"
  type        = any
}

variable "asg_policy" {
  description = "List of ASG policy variables"
  type        = any
}

variable "asg_sg" {
  description = "List of ASG SG variables"
  type        = any
}

variable "iam" {
  description = "List of IAM variables"
  type        = any
}

variable "windows_ingress_ports" {
  description = "List of ingress ports for Windows"
  type        = list(any)
}

variable "asg_tags_dynamic" {
  description = "List of tags for ASG"
  type        = list(map(string))
}


