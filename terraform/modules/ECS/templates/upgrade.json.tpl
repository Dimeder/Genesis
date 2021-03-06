[
        {

            "image": "sentry:9.1.2",
            "name": "upgrade",
            "essential": true,
            "networkMode": "awsvpc",
            "command": [ "upgrade", "--noinput" ],
              "environment" : [
                { "name" : "SENTRY_SECRET_KEY", "value" : "${SENTRY_SECRET_KEY}" },
                { "name" : "SENTRY_REDIS_PORT", "value" : "${SENTRY_REDIS_PORT}" },
                { "name" : "SENTRY_REDIS_HOST", "value" : "${SENTRY_REDIS_HOST}" },
                { "name" : "SENTRY_POSTGRES_HOST", "value" : "${SENTRY_POSTGRES_HOST}" },
                { "name" : "SENTRY_POSTGRES_PORT", "value" : "${SENTRY_POSTGRES_PORT}" },
                { "name" : "SENTRY_DB_NAME", "value" : "${SENTRY_DB_NAME}" },
                { "name" : "SENTRY_DB_USER", "value" : "${SENTRY_DB_USER}" },
                { "name" : "SENTRY_DB_PASSWORD", "value" : "${SENTRY_DB_PASSWORD}" }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/upgrade",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "upgrade"
                }
            }
        }
]