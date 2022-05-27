vpc_cidr = {
  default = "10.200.0.0/16"
}

public_subnets = {
  default = ["10.200.0.0/24", "10.200.1.0/24"]
}

private_subnets = {
  default = ["10.200.2.0/24", "10.200.3.0/24"]
}

azs = {
  default = ["us-east-1a", "us-east-1b"]
}

region = {
  default = "us-east-1"
}

default_tags = {
  environment    = "prod"
  role           = "production"
  Name           = "Test For CNB prod"
  owner          = "eanselmi@edrans.com"
  costCenter     = "SYSENG"
  tagVersion     = 1
  project        = "CNB"
  expirationDate = "12/12/2022"
}