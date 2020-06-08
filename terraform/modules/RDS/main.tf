
resource "aws_elasticache_subnet_group" "sentry" {
  name       = "sentry-cache-subnet"
  subnet_ids = [var.private-a, var.private-b]
}

resource "aws_elasticache_cluster" "sentry" {
  cluster_id           = "cluster-sentry"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  apply_immediately    = true
  security_group_ids   = [var.redis-sg]
  subnet_group_name    = aws_elasticache_subnet_group.sentry.id
}

resource "aws_db_subnet_group" "sentry-subnet-group" {
  name       = "sentry-db-subnet-group"
  subnet_ids = [var.private-a, var.private-b]
}

resource "aws_db_instance" "sentry-db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  identifier             = "sentry"
  name                   = var.SENTRY_DB_NAME
  username               = var.SENTRY_DB_USER
  password               = var.SENTRY_DB_PASSWORD
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.sentry-subnet-group.id
  vpc_security_group_ids = [var.db-sg]
}
