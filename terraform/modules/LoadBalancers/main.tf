resource "aws_lb" "sentry-alb" {
  name               = "sentry-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public-a, var.public-b]
  security_groups    = [var.sentry-sg]
  

  tags = {
    Name = "sentry-alb"
    type = "demo"
  }
}

resource "aws_lb_target_group" "sentry-tg" {
  name     = "sentry-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vps_id
  target_type = "ip"
  health_check {
      interval = 30
      path = "/"
      port = 9000
      protocol = "HTTP"
      timeout = 20
      healthy_threshold = 4
      unhealthy_threshold = 5
      matcher = "200,302"
  }
}

resource "aws_lb_listener" "sentry-alb" {
  load_balancer_arn = aws_lb.sentry-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sentry-tg.arn
  }
}
