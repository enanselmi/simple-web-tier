resource "aws_lb" "cnb_public_alb" {
  name               = "cnb-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cnb_public_alb_sg.id]
  subnets            = [for subnet in aws_subnet.cnb_public_subnets : subnet.id]

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "cnb_public_alb"
  #     enabled = true
  #   }

  tags = {
    Name = "cnb_public_alb"
  }
}

resource "aws_lb_target_group" "cnb_webserver_target" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }


  name        = "cnb-webserver-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.cnb_vpc.id
}

resource "aws_lb_listener" "cnb_public_alb_listener_http" {
  load_balancer_arn = aws_lb.cnb_public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "cnb_public_alb_listener_https" {
  load_balancer_arn = aws_lb.cnb_public_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:947941747067:certificate/af8bf54c-9a00-4159-b2e6-1832ba666213"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cnb_webserver_target.arn
  }
}


# resource "aws_lb_listener_rule" "static" {
#   listener_arn = aws_lb_listener.cnb_public_alb_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.cnb_webserver_target.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }


resource "aws_acm_certificate" "cnb_cert" {
  domain_name       = "cnbtest.edranslab.es"
  validation_method = "DNS"
  tags = {
    Environment = "CNB-test"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "cnb_public_alb_sg" {
  name        = "cnb_public_alb_sg"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.cnb_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cnb_public_alb_sg"
  }
}
