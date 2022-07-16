resource "aws_vpc" "cnb_vpc" {
  cidr_block           = var.vpc.cidr
  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_classiclink   = var.vpc.enable_classiclink
  instance_tenancy     = var.vpc.instance_tenancy
  tags = {
    Name = "${local.naming_prefix}-CNB-VPC-TEST"
  }
}

# ALTERNATIVE DNS CONFIGURATION

# resource "aws_vpc_dhcp_options" "dns_resolver" {
#   domain_name_servers = ["8.8.8.8", "8.8.4.4"]
# }

# resource "aws_vpc_dhcp_options_association" "dns_resolver" {
#   vpc_id          = aws_vpc.cnb_vpc.id
#   dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
# }

resource "aws_subnet" "cnb_public_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.public_subnets.default)
  cidr_block              = var.public_subnets.default[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = var.azs.default[count.index]
  tags = {
    Name = "${local.naming_prefix}-Public-Subnet-${count.index}-${var.azs.default[count.index]}"
  }
}

resource "aws_subnet" "cnb_private_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.private_subnets.default)
  cidr_block              = var.private_subnets.default[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = var.azs.default[count.index]
  tags = {
    Name = "${local.naming_prefix}-Private-Subnet-${count.index}-${var.azs.default[count.index]}"
  }
}

resource "aws_internet_gateway" "cnb_igw" {
  vpc_id = aws_vpc.cnb_vpc.id
  tags = {
    Name = "${local.naming_prefix}-CNB-IGW"
  }
}

resource "aws_eip" "eips" {
  count      = length(var.public_subnets.default)
  vpc        = true
  depends_on = [aws_internet_gateway.cnb_igw]
  tags = {
    Name = "${local.naming_prefix}-CNB-EIP-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnets.default)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.cnb_public_subnets[count.index].id
  depends_on    = [aws_internet_gateway.cnb_igw, aws_eip.eips]
  tags = {
    Name = "${local.naming_prefix}-CNB-NGW-${count.index}"
  }
}

resource "aws_route_table" "cnb_public_crt" {
  vpc_id = aws_vpc.cnb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cnb_igw.id
  }
  tags = {
    Name = "${local.naming_prefix}-CNB-Public-CRT"
  }
}

resource "aws_route_table_association" "cnb_crta_public_subnets" {
  count          = length(var.public_subnets.default)
  subnet_id      = aws_subnet.cnb_public_subnets[count.index].id
  route_table_id = aws_route_table.cnb_public_crt.id
}

resource "aws_route_table" "cnb_private_crts" {
  count  = length(var.private_subnets.default)
  vpc_id = aws_vpc.cnb_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  tags = {
    Name = "${local.naming_prefix}-CNB-PRIVATE-CRT-${var.azs.default[count.index]}"
  }
}

resource "aws_route_table_association" "cnb_crta_private_subnets" {
  count          = length(var.private_subnets.default)
  subnet_id      = aws_subnet.cnb_private_subnets[count.index].id
  route_table_id = aws_route_table.cnb_private_crts[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cnb_vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.naming_prefix}-S3-ENDPOINT"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_public_rt" {
  count           = length(var.private_subnets.default)
  route_table_id  = aws_route_table.cnb_private_crts[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.cnb_vpc.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.naming_prefix}-DynamoDB-ENDPOINT"
  }
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_public_rt" {
  count           = length(var.private_subnets.default)
  route_table_id  = aws_route_table.cnb_private_crts[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}


resource "aws_security_group" "ssm_vpc_endpoint_sg" {
  name        = "ssm_vpc_endpoint_sg"
  description = "ssm_vpc_endpoint_sg"
  vpc_id      = aws_vpc.cnb_vpc.id

  ingress {
    description     = "HTTPS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cnb_webserver_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.naming_prefix}-SSM_VPC_ENDPOINT_SG"
  }
}


#VPCE for SSM

# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id            = aws_vpc.cnb_vpc.id
#   service_name      = "com.amazonaws.us-east-1.ssm"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.ssm_vpc_endpoint_sg.id]
#   subnet_ids         = aws_subnet.cnb_private_subnets[*].id

#   private_dns_enabled = true

#   tags = {
#     Name = "${local.naming_prefix}-SSM_ENDPOINT"
#   }
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id            = aws_vpc.cnb_vpc.id
#   service_name      = "com.amazonaws.us-east-1.ec2messages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.ssm_vpc_endpoint_sg.id]
#   subnet_ids         = aws_subnet.cnb_private_subnets[*].id

#   private_dns_enabled = true

#   tags = {
#     Name = "${local.naming_prefix}-EC2MESSAGES_ENDPOINT"
#   }
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id            = aws_vpc.cnb_vpc.id
#   service_name      = "com.amazonaws.us-east-1.ssmmessages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [aws_security_group.ssm_vpc_endpoint_sg.id]
#   subnet_ids         = aws_subnet.cnb_private_subnets[*].id

#   private_dns_enabled = true

#   tags = {
#     Name = "${local.naming_prefix}-SSMMESSAGES_ENDPOINT"
#   }
# }

