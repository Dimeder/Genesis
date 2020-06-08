[
  {
      "cpu": 256,
      "image": "redis:latest",
      "memory": 512,
      "essential": true,
      "name": "redis",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": 6379
        }
      ],
      "requiresCompatibilities": [ 
       "FARGATE" 
    ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/redis",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "redis"
        }
    }
  }
]

