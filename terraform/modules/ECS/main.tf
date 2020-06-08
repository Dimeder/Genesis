resource "aws_ecs_cluster" "main" {
  name = "sentry-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "main"
  container_definitions    = data.template_file.main.rendered
  task_role_arn            = var.aws_iam_role
  execution_role_arn       = var.aws_iam_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 4096
}

data "template_file" "main" {
  template = file("modules/ECS/templates/main.json.tpl")
  vars = {
    SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
    SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
    SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
    SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
    SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
    SENTRY_DB_NAME       = var.SENTRY_DB_NAME
    SENTRY_DB_USER       = var.SENTRY_DB_USER
    SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
  }
}

resource "aws_ecs_service" "main" {
  name                = "main-service"
  cluster             = aws_ecs_cluster.main.id
  task_definition     = aws_ecs_task_definition.main.arn
  launch_type         = "FARGATE"
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  network_configuration {
    subnets         = [var.private-a, var.private-b]
    security_groups = [var.ecs-sg ]
  }
  load_balancer {
    target_group_arn = var.sentry-tg
    container_name   = "web"
    container_port   = var.app_port
  }
}

resource "aws_ecs_task_definition" "upgrade" {
  family                   = "upgrade"
  container_definitions    = data.template_file.upgrade.rendered
  task_role_arn            = var.aws_iam_role
  execution_role_arn       = var.aws_iam_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 2048
}

data "template_file" "upgrade" {
  template = file("modules/ECS/templates/upgrade.json.tpl")
  vars = {
    SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
    SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
    SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
    SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
    SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
    SENTRY_DB_NAME       = var.SENTRY_DB_NAME
    SENTRY_DB_USER       = var.SENTRY_DB_USER
    SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
  }
}

resource "aws_ecs_service" "upgrade" {
  name                = "upgrade-service"
  cluster             = aws_ecs_cluster.main.id
  task_definition     = aws_ecs_task_definition.upgrade.arn
  launch_type         = "FARGATE"
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  network_configuration {
    subnets         = [var.private-a, var.private-b]
    security_groups = [var.ecs-sg ]
  }
}

# resource "aws_ecs_task_definition" "user" {
#   family                   = "user"
#   container_definitions    = data.template_file.user.rendered
#   task_role_arn            = var.aws_iam_role
#   execution_role_arn       = var.aws_iam_role
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512
# }

# data "template_file" "user" {
#   template = file("modules/ECS/templates/user.json.tpl")
#   vars = {
#     SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
#     SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
#     SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
#     SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
#     SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
#     SENTRY_DB_NAME       = var.SENTRY_DB_NAME
#     SENTRY_DB_USER       = var.SENTRY_DB_USER
#     SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
#   }
# }

# resource "aws_ecs_service" "user" {
#   name                = "user-service"
#   cluster             = aws_ecs_cluster.main.id
#   task_definition     = aws_ecs_task_definition.user.arn
#   launch_type         = "FARGATE"
#   desired_count       = 1
#   scheduling_strategy = "REPLICA"
#   network_configuration {
#     subnets         = [var.private-a, var.private-b]
#     security_groups = [var.ecs-sg ]
#   }
# }

# resource "aws_ecs_task_definition" "web" {
#   family                   = "web"
#   container_definitions    = data.template_file.web.rendered
#   task_role_arn            = var.aws_iam_role
#   execution_role_arn       = var.aws_iam_role
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512
# }

# data "template_file" "web" {
#   template = file("modules/ECS/templates/web.json.tpl")
#   vars = {
#     SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
#     SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
#     SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
#     SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
#     SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
#     SENTRY_DB_NAME       = var.SENTRY_DB_NAME
#     SENTRY_DB_USER       = var.SENTRY_DB_USER
#     SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
#   }
# }

# resource "aws_ecs_service" "web" {
#   name                = "web-service"
#   cluster             = aws_ecs_cluster.main.id
#   task_definition     = aws_ecs_task_definition.web.arn
#   launch_type         = "FARGATE"
#   desired_count       = 1
#   scheduling_strategy = "REPLICA"
#   network_configuration {
#     subnets         = [var.private-a, var.private-b]
#     security_groups = [var.ecs-sg ]
#   }
#   load_balancer {
#     target_group_arn = var.sentry-tg
#     container_name   = "web"
#     container_port   = var.app_port
#   }
# }

# resource "aws_ecs_task_definition" "cron" {
#   family                   = "cron"
#   container_definitions    = data.template_file.cron.rendered
#   task_role_arn            = var.aws_iam_role
#   execution_role_arn       = var.aws_iam_role
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512
# }

# data "template_file" "cron" {
#   template = file("modules/ECS/templates/cron.json.tpl")
#   vars = {
#     SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
#     SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
#     SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
#     SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
#     SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
#     SENTRY_DB_NAME       = var.SENTRY_DB_NAME
#     SENTRY_DB_USER       = var.SENTRY_DB_USER
#     SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
#   }
# }

# resource "aws_ecs_service" "cron" {
#   name                = "cron-service"
#   cluster             = aws_ecs_cluster.main.id
#   task_definition     = aws_ecs_task_definition.cron.arn
#   launch_type         = "FARGATE"
#   desired_count       = 1
#   scheduling_strategy = "REPLICA"
#   network_configuration {
#     subnets         = [var.private-a, var.private-b]
#     security_groups = [var.ecs-sg ]
#   }
# }

# resource "aws_ecs_task_definition" "worker" {
#   family                   = "worker"
#   container_definitions    = data.template_file.worker.rendered
#   task_role_arn            = var.aws_iam_role
#   execution_role_arn       = var.aws_iam_role
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512
# }

# data "template_file" "worker" {
#   template = file("modules/ECS/templates/worker.json.tpl")
#   vars = {
#     SENTRY_SECRET_KEY    = var.SENTRY_SECRET_KEY
#     SENTRY_REDIS_PORT    = var.SENTRY_REDIS_PORT
#     SENTRY_REDIS_HOST    = var.SENTRY_REDIS_HOST
#     SENTRY_POSTGRES_HOST = var.SENTRY_POSTGRES_HOST
#     SENTRY_POSTGRES_PORT = var.SENTRY_POSTGRES_PORT
#     SENTRY_DB_NAME       = var.SENTRY_DB_NAME
#     SENTRY_DB_USER       = var.SENTRY_DB_USER
#     SENTRY_DB_PASSWORD   = var.SENTRY_DB_PASSWORD
#   }
# }

# resource "aws_ecs_service" "worker" {
#   name                = "worker-service"
#   cluster             = aws_ecs_cluster.main.id
#   task_definition     = aws_ecs_task_definition.worker.arn
#   launch_type         = "FARGATE"
#   desired_count       = 1
#   scheduling_strategy = "REPLICA"
#   network_configuration {
#     subnets         = [var.private-a, var.private-b]
#     security_groups = [var.ecs-sg ]
#   }
# }
