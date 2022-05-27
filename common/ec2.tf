resource "aws_launch_configuration" "cnb_webserver" {
  image_id             = "ami-0022f774911c1d690"
  instance_type        = "t2.micro"
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

  min_size = 2
  max_size = 4

  target_group_arns = [aws_lb_target_group.cnb_webserver_target.arn]
  health_check_type = "EC2"

  warm_pool {
    pool_state                  = "Stopped"
    min_size                    = 2
    max_group_prepared_capacity = 10

    # instance_reuse_policy {
    #   reuse_on_scale_in = true
    # }
  }

  tag {
    key                 = "Name"
    value               = "CNB_webserver"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "cnb_webserver_policy" {
  name                   = "cnb_webserver_policy"
  autoscaling_group_name = aws_autoscaling_group.cnb_webserver.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "40.0"
  }
}



resource "aws_security_group" "cnb_webserver_sg" {
  name        = "cnb_webserver_sg"
  description = "Allow HTTPS inbound traffic from ALB"
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
  name = "CNB-EC2-SSM"
  role = aws_iam_role.cnb_ec2_ssm.name
}

resource "aws_iam_role" "cnb_ec2_ssm" {
  name = "CNB-EC2-SSM"
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
  name = "cnb_ec2_ssm"
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
