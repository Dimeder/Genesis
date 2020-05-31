output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "redis_hostname" {
  value = aws_elasticache_cluster.sentry.cache_nodes
}

output "db-endpoint" {
  value = aws_db_instance.sentry-db.address
}
