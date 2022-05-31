resource "aws_instance" "cnb_windows" {
  #ami                   = "ami-0e2c8caa770b20b08"
  ami                    = "ami-0da644b56519f3a2f"
  instance_type          = "c5.xlarge"
  key_name               = "windows-test"
  subnet_id              = aws_subnet.cnb_private_subnets[0].id
  vpc_security_group_ids = [aws_security_group.windows_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
  # network_interface {
  #   network_interface_id = aws_network_interface.windows_eni.id
  #   device_index         = 0
  # }
}


# resource "aws_network_interface" "windows_eni" {
#   subnet_id = aws_subnet.cnb_private_subnets[0].id
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



resource "aws_launch_configuration" "cnb_webserver" {
  image_id             = var.launch_configuration.image_id
  instance_type        = var.launch_configuration.instance_type
  security_groups      = [aws_security_group.cnb_webserver_sg.id]
  user_data            = file("../../common/user-data-apache.sh")
  iam_instance_profile = aws_iam_instance_profile.cnb_ec2_ssm.arn
  #key_name = aws_key_pair.ssh.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cnb_webserver" {
  launch_configuration = aws_launch_configuration.cnb_webserver.id
  vpc_zone_identifier  = [for subnet in aws_subnet.cnb_private_subnets : subnet.id]

  min_size = var.asg.min_size
  max_size = var.asg.max_size

  target_group_arns = [aws_lb_target_group.cnb_webserver_target.arn]
  health_check_type = var.asg.health_check_type

  warm_pool {
    pool_state                  = var.asg.warm_pool_state
    min_size                    = var.asg.warm_min_size
    max_group_prepared_capacity = var.asg.warm_max_group_prepared_capacity

    # instance_reuse_policy {
    #   reuse_on_scale_in = true
    # }
  }

  tags = var.asg_tags.default

}

resource "aws_autoscaling_policy" "cnb_webserver_policy" {
  name                   = var.asg_policy.name
  autoscaling_group_name = aws_autoscaling_group.cnb_webserver.name
  policy_type            = var.asg_policy.policy_type
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.asg_policy.predefined_metric_type
    }
    target_value = var.asg_policy.target_value
  }
}



resource "aws_security_group" "cnb_webserver_sg" {
  name        = var.asg_sg.name
  description = var.asg_sg.description
  vpc_id      = aws_vpc.cnb_vpc.id

  ingress {
    description     = "HTTPS from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.cnb_public_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cnb_webserver_sg"
  }
}

resource "aws_iam_instance_profile" "cnb_ec2_ssm" {
  name = var.iam.instance_profile_name
  role = aws_iam_role.cnb_ec2_ssm.name
}

resource "aws_iam_role" "cnb_ec2_ssm" {
  name = var.iam.iam_role_name
  # path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cnb_ec2_ssm" {
  name = var.iam.iam_role_policy_name
  role = aws_iam_role.cnb_ec2_ssm.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
