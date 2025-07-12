
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2     # 2 consecutive successes = healthy
    unhealthy_threshold = 15    # 15 consecutive failures = unhealthy (7.5 minutes)
    timeout             = 5     # 5 second timeout per check
    interval            = 30    # Check every 30 seconds
    path                = var.health_check_path
    matcher             = "200"
    port                = "traffic-port"
    protocol            = var.target_protocol
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg"
  })
}

# Target Group Attachment - Connect EC2 to Load Balancer
resource "aws_lb_target_group_attachment" "main" {
  count = length(var.target_instance_ids)
  
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.target_port
}

# Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Optional HTTPS Listener (if certificate is provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# HTTP to HTTPS redirect (if HTTPS listener exists)
resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count = var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
