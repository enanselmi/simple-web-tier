resource "aws_lb" "cnb_public_alb" {
  name               = var.alb.name
  internal           = var.alb.internal
  load_balancer_type = var.alb.load_balancer_type
  security_groups    = [aws_security_group.cnb_public_alb_sg.id]
  subnets            = [for subnet in aws_subnet.cnb_public_subnets : subnet.id]

  enable_deletion_protection = var.alb.enable_deletion_protection

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
    interval            = var.alb_target_group.interval
    path                = var.alb_target_group.path
    protocol            = var.alb_target_group.protocol
    timeout             = var.alb_target_group.timeout
    healthy_threshold   = var.alb_target_group.healthy_threshold
    unhealthy_threshold = var.alb_target_group.unhealthy_threshold
  }


  name        = var.alb_target_group.name
  port        = var.alb_target_group.port
  protocol    = var.alb_target_group.protocol
  target_type = var.alb_target_group.target_type
  vpc_id      = aws_vpc.cnb_vpc.id
}

resource "aws_lb_listener" "cnb_public_alb_listener_http" {
  load_balancer_arn = aws_lb.cnb_public_alb.arn
  port              = var.cnb_public_alb_listener_http.port
  protocol          = var.cnb_public_alb_listener_http.protocol

  default_action {
    type             = var.cnb_public_alb_listener_https.type
    target_group_arn = aws_lb_target_group.cnb_webserver_target.arn
  }
  # default_action {
  #   type = var.cnb_public_alb_listener_http.type

  #   redirect {
  #     port        = var.cnb_public_alb_listener_http.port_redirect
  #     protocol    = var.cnb_public_alb_listener_http.redirect_protocol
  #     status_code = var.cnb_public_alb_listener_http.status_code
  #   }
  # }
}

# resource "aws_lb_listener" "cnb_public_alb_listener_https" {
#   load_balancer_arn = aws_lb.cnb_public_alb.arn
#   port              = var.cnb_public_alb_listener_https.port
#   protocol          = var.cnb_public_alb_listener_https.protocol
#   ssl_policy        = var.cnb_public_alb_listener_https.ssl_policy
#   certificate_arn   = var.cnb_public_alb_listener_https.certificate_arn

#   default_action {
#     type             = var.cnb_public_alb_listener_https.type
#     target_group_arn = aws_lb_target_group.cnb_webserver_target.arn
#   }
# }


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

# resource "aws_acm_certificate" "cnb_cert" {
#   domain_name       = var.cnb_cert.domain_name
#   validation_method = var.cnb_cert.validation_method
#   tags = {
#     Environment = "CNB-test"
#   }
#   lifecycle {
#     create_before_destroy = var.cnb_cert.create_before_destroy
#   }
# }

resource "aws_security_group" "cnb_public_alb_sg" {
  name        = var.cnb_public_alb_sg.name
  description = var.cnb_public_alb_sg.description
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
    Name = "${local.naming_prefix}-SG-ALB"
  }
}
