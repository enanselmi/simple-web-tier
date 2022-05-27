vpc_cidr = {
  default = "10.100.0.0/16"
}

public_subnets = {
  default = ["10.100.0.0/24", "10.100.1.0/24"]
}

private_subnets = {
  default = ["10.100.2.0/24", "10.100.3.0/24"]
}

azs = {
  default = ["us-east-1c", "us-east-1d"]
}

region = {
  default = "us-east-1"
}

default_tags = {
  environment    = "dev"
  role           = "development"
  Name           = "Test For CNB dev"
  owner          = "eanselmi@edrans.com"
  costCenter     = "SYSENG"
  tagVersion     = 1
  project        = "CNB"
  expirationDate = "12/12/2022"
}
