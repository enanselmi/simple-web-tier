resource "aws_instance" "cnb_windows_ad" {
  #ami = "ami-0e4eb3558ed6398c8" #Ami used in CNB prd account (USA) Windows 2022

  # ami                    = "ami-0efd91e0e06eafc06" #Custom AMI With AWS CLI included
  #ami = "ami-041306c411c38a789" #Windows 2019 original
  ami = "ami-00e43ba787345b2df" #Windows 2019 custom

  instance_type          = "c5.large"
  key_name               = "windows-test"
  subnet_id              = aws_subnet.cnb_private_subnets[0].id
  vpc_security_group_ids = [aws_security_group.windows_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
  user_data              = file("../../common/templates/user-data/user_data_dc.ps1")
  private_ip             = "10.200.2.10"
  tags = {
    platform = "windows"
    Name     = "Windows-2019"
  }
  root_block_device {
    encrypted   = true
    kms_key_id  = module.kms_ebs.key_arn
    volume_size = "70"
    volume_type = "gp3"
    #iops        = 500
    #tags        = merge(tomap({ "Name" = "${local.naming_prefix}-ebsroot-FSVM1-${var.tags.region}" }), var.tags)
    #delete_on_termination = false
  }
}

resource "aws_ebs_volume" "cnb_windows_ad_extra_disk" {
  availability_zone = var.azs.default[0]
  type              = "io2"
  size              = 127
  iops              = 500

  encrypted  = true
  kms_key_id = module.kms_ebs.key_arn
}

resource "aws_volume_attachment" "cnb_windows_ad_extra_disk" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.cnb_windows_ad_extra_disk.id
  instance_id = aws_instance.cnb_windows_ad.id
}


# resource "aws_instance" "cnb_windows_domain_member" {
#   #ami = "ami-0e4eb3558ed6398c8" #Ami used in CNB prd account (USA)

#   ami                    = "ami-0efd91e0e06eafc06" #Custom AMI With AWS CLI included
#   instance_type          = "c5.xlarge"
#   key_name               = "windows-test"
#   subnet_id              = aws_subnet.cnb_private_subnets[0].id
#   vpc_security_group_ids = [aws_security_group.windows_instance.id]
#   iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
#   user_data              = file("../../common/user_data_domain_join.ps1")
#   tags = {
#     platform = "windows"
#     Name     = "Windows-2022-biss"
#   }
# }

resource "aws_security_group" "windows_instance" {
  name   = "windows-security-group"
  vpc_id = aws_vpc.cnb_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



