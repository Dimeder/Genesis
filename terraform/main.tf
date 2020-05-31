provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "dimeder"
    key    = "terraform/genesis.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_eip" "gw" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "lb" {
  name        = "tf-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "tf-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "tf-ecs-rds"
  description = "allow inbound access from the ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis" {
  name        = "tf-ecs-redis"
  description = "allow inbound access from the ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
  name            = "sentry"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "sentry" {
  name        = "sentry"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb_listener" "sentry" {
  load_balancer_arn = aws_alb.main.id
  port              = "9000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.sentry.arn
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "sentry-cluster"
}

resource "aws_ecs_task_definition" "sentry" {
  family                   = "sentry"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = <<DEFINITION
[
  { 
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "sentry",
    "networkMode": "awsvpc",
    "taskRoleArn": "arn:aws:iam::875746189822:role/myEcsTaskExecutionRole",
    "executionRoleArn": "arn:aws:iam::875746189822:role/myEcsTaskExecutionRole",
    "command": [
        "upgrade"
      ],
    "environment": [
        {
          "name": "SENTRY_SECRET_KEY",
          "value": "${var.s_key}"
        },
        {
          "name": "SENTRY_POSTGRES_HOST",
          "value": "${var.db_host}"
        },
        {
          "name": "SENTRY_POSTGRES_PORT",
          "value": "5432"
        },
        {
          "name": "SENTRY_DB_NAME",
          "value": "${var.name_db}"
        },
        {
          "name": "SENTRY_DB_USER",
          "value": "${var.username}"
        },
        {
          "name": "SENTRY_DB_PASSWORD",
          "value": "${var.password}"
        },
        {
          "name": "SENTRY_REDIS_HOST",
          "value": "${var.redis_host}"
        },
        {
          "name": "SENTRY_REDIS_PORT",
          "value": "6379"
        }
      ],
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "requiresCompatibilities": [ 
       "FARGATE" 
    ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "main" {
  name            = "sentry-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.sentry.id
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.sentry.arn
    container_name   = "sentry"
    container_port   = var.app_port
  }
  depends_on = [
    "aws_alb_listener.sentry",
  ]
}

resource "aws_elasticache_subnet_group" "sentry" {
  name       = "sentry-cache-subnet"
  subnet_ids = aws_subnet.private.*.id
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
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.sentry.id
}

resource "aws_db_subnet_group" "sentry-subnet-group" {
  name       = "sentry-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "sentry-db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  identifier             = "sentry"
  name                   = var.name_db
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.sentry-subnet-group.id
  vpc_security_group_ids = [aws_security_group.rds.id]
}