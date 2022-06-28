public_subnets = {
  default = ["10.200.0.0/24", "10.200.1.0/24"]
}

private_subnets = {
  default = ["10.200.2.0/24", "10.200.3.0/24"]
}

azs = {
  default = ["us-east-1a", "us-east-1b"]
}

region = {
  default = "us-east-1"
}

default_tags = {
  environment    = "prod"
  role           = "production"
  Name           = "Test For CNB prod"
  owner          = "eanselmi@edrans.com"
  costCenter     = "SYSENG"
  tagVersion     = 1
  project        = "CNB"
  expirationDate = "12/12/2022"
}

alb = {
  name                       = "cnb-public-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false

}

alb_target_group = {
  interval            = 10
  path                = "/"
  protocol            = "HTTP"
  timeout             = 5
  healthy_threshold   = 5
  unhealthy_threshold = 2
  name                = "cnb-webserver-target"
  port                = 80
  protocol            = "HTTP"
  target_type         = "instance"

}

cnb_public_alb_listener_http = {
  port              = "80"
  protocol          = "HTTP"
  type              = "redirect"
  port_redirect     = "443"
  redirect_protocol = "HTTPS"
  status_code       = "HTTP_301"
}

cnb_public_alb_listener_https = {
  port            = "443"
  protocol        = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:947941747067:certificate/af8bf54c-9a00-4159-b2e6-1832ba666213"
  type            = "forward"
}

cnb_cert = {
  domain_name           = "cnbtest.edranslab.es"
  validation_method     = "DNS"
  create_before_destroy = true
}

cnb_public_alb_sg = {
  name        = "cnb_public_alb_sg"
  description = "Allow HTTPS inbound traffic"
}

asg_tags = {
  default = [
    {
      key                 = "environment"
      value               = "prod"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "production"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "Test For CNB prod"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = "eanselmi@edrans.com"
      propagate_at_launch = true
    },
    {
      key                 = "costCenter"
      value               = "SYSENG"
      propagate_at_launch = true
    },
    {
      key                 = "tagVersion"
      value               = 1
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "CNB"
      propagate_at_launch = true
    },
    {
      key                 = "expirationDate"
      value               = "12/12/2022"
      propagate_at_launch = true
    },
  ]
}

vpc = {
  cidr                 = "10.200.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

}

launch_configuration = {
  instance_type = "t2.micro"
}

asg = {
  min_size                         = 2
  max_size                         = 4
  health_check_type                = "EC2"
  warm_pool_state                  = "Stopped"
  warm_min_size                    = 2
  warm_max_group_prepared_capacity = 6
}

asg_policy = {
  name                   = "cnb_webserver_policy"
  policy_type            = "TargetTrackingScaling"
  predefined_metric_type = "ASGAverageCPUUtilization"
  target_value           = "40.0"
}

asg_sg = {
  name        = "cnb_webserver_sg"
  description = "Allow HTTPS inbound traffic from ALB"
}

iam = {
  instance_profile_name = "CNB-EC2-SSM"
  iam_role_name         = "CNB-EC2-SSM"
  iam_role_policy_name  = "cnb_ec2_ssm"
}

