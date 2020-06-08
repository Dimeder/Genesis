output "vps_id" {
  value = aws_vpc.vpc.id
}
output "private-a" {
  value = aws_subnet.private-a.id
}
output "private-b" {
  value = aws_subnet.private-b.id
}
output "public-a" {
  value = aws_subnet.public-a.id
}
output "public-b" {
  value = aws_subnet.public-b.id
}
output "alb-sg" {
  value = aws_security_group.alb-sg.id
}
output "redis" {
  value = aws_security_group.redis.id
}
output "db" {
  value = aws_security_group.db.id
}
output "ecs" {
  value = aws_security_group.ecs.id
}



