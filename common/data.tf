data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*"]
  }
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
