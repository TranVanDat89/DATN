
#Frontend Target Group
resource "aws_lb_target_group" "frontend_target_group" {
  name        = "fe-target-group"
  port        = 4200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "4200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

#Backend Target Group
resource "aws_lb_target_group" "backend_target_group" {
  name        = "be-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/ecommerce/api/v1/categories"
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}
#Application Load Balancer
resource "aws_lb" "load_balancer" {
  name               = "final-assignment-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.load_balance_security_group_ids
  subnets            = var.load_balance_subnet_ids
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "final-assignment-alb"
  }
}

# HTTP Listener - Redirect to HTTPS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
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

  tags = {
    Name = "http-listener"
  }
}

# HTTPS Listener - Main listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  # Default action forward to frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

  tags = {
    Name = "https-listener"
  }
}

# Backend API Rule for HTTPS Listener
resource "aws_lb_listener_rule" "backend_api_rule_https" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/ecommerce/api/v1/*"]
    }
  }

  tags = {
    Name = "backend-api-rule-https"
  }
}

# Additional rules for better routing
resource "aws_lb_listener_rule" "frontend_static_assets_1" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["*.js", "*.css", "*.png", "*.jpg", "*.jpeg"]
    }
  }

  tags = {
    Name = "frontend-static-assets-1"
  }
}

resource "aws_lb_listener_rule" "frontend_static_assets_2" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 21

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["*.gif", "*.ico", "*.svg", "/assets/*", "/static/*"]
    }
  }

  tags = {
    Name = "frontend-static-assets-2"
  }
}


# Health check endpoints rule
resource "aws_lb_listener_rule" "health_check_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 30

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/health", "/healthcheck", "/.well-known/health-check"]
    }
  }

  tags = {
    Name = "health-check-rule"
  }
}