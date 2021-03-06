#WINDOWS AD DNS - USE ONLY FOR AD TESTING

# resource "aws_vpc_dhcp_options" "dhcp_custom_set" {
#   domain_name_servers = ["10.200.2.11"]
# }
# resource "aws_vpc_dhcp_options_association" "dhcp_custom_set" {
#   vpc_id          = aws_vpc.cnb_vpc.id
#   dhcp_options_id = aws_vpc_dhcp_options.dhcp_custom_set.id
# }


resource "aws_instance" "cnb_windows_ad" {

  #ami = "ami-0e4eb3558ed6398c8" #Ami used in CNB prd account (USA) Windows 2022
  #ami = "ami-0e1a729017e59e409" #Windows 2022 original
  #ami = "ami-041306c411c38a789" #Windows 2019 original
  ami = "ami-06a0bd14ccbce0c87" #2022 custom with aws cli


  instance_type          = "c5.large"
  key_name               = "windows-test"
  subnet_id              = aws_subnet.cnb_private_subnets[0].id
  vpc_security_group_ids = [aws_security_group.windows_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
  user_data              = file("../../common/templates/user-data/user_data_dc.ps1")
  private_ip             = "10.200.2.11"
  tags = {
    platform = "windows"
    Name     = "${local.naming_prefix}-Windows-2022"
    Backup   = "True"
  }
  root_block_device {
    encrypted = true
    #kms_key_id  = module.kms_ebs.key_arn
    volume_size = "70"
    volume_type = "gp3"
    #iops        = 500
    #tags        = merge(tomap({ "Name" = "${local.naming_prefix}-ebsroot-FSVM1-${var.tags.region}" }), var.tags)
    #delete_on_termination = false
    tags = merge(var.default_tags, { Name = "${local.naming_prefix}-Windows-AD-EBS" }, { Backup = "True" })
  }
}

resource "aws_ebs_volume" "cnb_windows_ad_extra_disk" {
  availability_zone = var.azs.default[0]
  type              = "io2"
  size              = 127
  iops              = 500

  encrypted  = true
  kms_key_id = module.kms_ebs.key_arn
  tags = {
    Backup = "True"
  }
}

resource "aws_volume_attachment" "cnb_windows_ad_extra_disk" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.cnb_windows_ad_extra_disk.id
  instance_id = aws_instance.cnb_windows_ad.id
}


# resource "aws_instance" "cnb_windows_domain_member" {
#   ami                    = "ami-06a0bd14ccbce0c87" #2022 custom with aws cli
#   instance_type          = "c5.large"
#   key_name               = "windows-test"
#   subnet_id              = aws_subnet.cnb_private_subnets[0].id
#   vpc_security_group_ids = [aws_security_group.windows_instance.id]
#   iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
#   user_data              = file("../../common/templates/user-data/user_data_domain_join.ps1")
#   tags = {
#     platform = "windows"
#     Name     = "${local.naming_prefix}-Windows-2022-Member"
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
  tags = {
    Name = "${local.naming_prefix}-SG-Windows"
  }
}


#Ejemplo de SG con dynamic block

resource "aws_security_group" "windows_instance_dynamic" {
  name   = "windows-security-group-dynamic"
  vpc_id = aws_vpc.cnb_vpc.id

  dynamic "ingress" {
    for_each = var.windows_ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.windows_instance.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.naming_prefix}-SG-Windows-Dynamic"
  }

}



