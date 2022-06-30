# resource "aws_instance" "linux_pub" {
#   #ami = "ami-0e4eb3558ed6398c8" #Ami used in CNB prd account (USA)

#   ami                    = data.aws_ami.amazon-linux-2.id
#   instance_type          = "c5.xlarge"
#   key_name               = "windows-test"
#   subnet_id              = aws_subnet.cnb_public_subnets[0].id
#   vpc_security_group_ids = [aws_security_group.cnb_webserver_sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.cnb_ec2_ssm.name
#   user_data              = file("../../common/user-data-apache.sh")

#   tags = {
#     platform = "AMZLINUX2"
#     Name     = "L-pub"
#   }
# }

resource "aws_launch_configuration" "cnb_webserver" {
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = var.launch_configuration.instance_type
  security_groups      = [aws_security_group.cnb_webserver_sg.id]
  user_data            = file("../../common/data/user-data-apache.sh")
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

