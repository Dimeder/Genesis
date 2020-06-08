[
  {
    "cpu": 256,
    "image": "postgres:9.5",
    "memory": 512,
    "name": "postgres",
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
    {
        "containerPort": 5432,
        "hostPort": 5432
    }
        ],
        "environment" : [
        { "name" : "POSTGRES_USER", "value" : "${SENTRY_DB_USER}" },
        { "name" : "POSTGRES_DB", "value" :  "${SENTRY_DB_NAME}"},
        { "name" : "POSTGRES_PASSWORD", "value" : "${SENTRY_DB_PASSWORD}"}
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
                "awslogs-group": "/ecs/postgres",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "postgres"
        }
    }
  }
]