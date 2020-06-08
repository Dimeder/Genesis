output "redis-node" {
  value = aws_elasticache_cluster.sentry.cache_nodes[0].address
}
output "postgres-db" {
  value = aws_db_instance.sentry-db.address
}


