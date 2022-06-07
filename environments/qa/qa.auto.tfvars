env = {
  name       = "qa"
  prefix     = "qa"
  region     = "us-east-1"
  key_name   = "qa"
  project    = "template"
  costCenter = "CloudEng"
  owner      = "default"
}

vpc = {
  cidr_block = "10.100.0.0/16"
  newbits    = "3"
}

vpc_azs_list = [
  "us-east-1d",
  "us-east-1e",
]
