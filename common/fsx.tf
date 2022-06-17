# resource "aws_fsx_windows_file_system" "rdp_fsvm" {
#   #kms_key_id       = module.kms_fsx.key_arn
#   storage_capacity = 100
#   #subnet_ids          = aws_subnet.sr1_private_subnets_databases[*].id
#   subnet_ids          = [aws_subnet.cnb_private_subnets[0].id]
#   throughput_capacity = 1024
#   #deployment_type     = "MULTI_AZ_1"
#   #preferred_subnet_id = aws_subnet.sr1_private_subnets_databases[0].id
#   security_group_ids = [aws_security_group.sr1_fsx_sg.id]

#   self_managed_active_directory {
#     dns_ips     = ["10.200.2.10"]
#     domain_name = "contoso.local"
#     username    = "administrator"
#     password    = "Pa##w0rd"
#   }
# }

# resource "aws_security_group" "sr1_fsx_sg" {
#   name   = "test-fsx"
#   vpc_id = aws_vpc.cnb_vpc.id
# }

# resource "aws_security_group_rule" "sr1_fsx_sg_egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sr1_fsx_sg.id
# }

# resource "aws_security_group_rule" "sr1_fsx_sg_smb" {
#   description = "Allow SMB Client"
#   type        = "ingress"
#   from_port   = 445
#   to_port     = 445
#   protocol    = "tcp"
#   cidr_blocks = [var.vpc.cidr]

#   security_group_id = aws_security_group.sr1_fsx_sg.id
# }

# resource "aws_security_group_rule" "sr1_fsx_sg_administrator" {
#   description = "Allow Administrator"
#   type        = "ingress"
#   from_port   = 5985
#   to_port     = 5985
#   protocol    = "tcp"
#   cidr_blocks = [var.vpc.cidr]

#   security_group_id = aws_security_group.sr1_fsx_sg.id
# }
