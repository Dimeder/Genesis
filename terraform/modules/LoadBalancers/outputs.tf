output "sentry-alb" {
  value = aws_lb.sentry-alb.arn
}
output "sentry-tg" {
  value = aws_lb_target_group.sentry-tg.arn
}

