#Create ECS Cluster
resource "aws_ecs_cluster" "final-assignment_ecs_cluster" {
  name = "final-assignment-ecs-cluster"
  
}
#Create ECS Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name = "final-assignment-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "final-assignment-task-execution-policy"
  description = "Policy for ECS task execution role"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

#Create ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "final-assignment-task-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_policy" "ecs_task_role_policy" {
  name        = "final-assignment-task-role-policy"
  description = "Policy for ECS task role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue"
          # "ssm:GetParameters",
          # "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.rds_password_secret_arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

####### Frontend ######
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = "ecs/ecs/final-assignment-fe"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend-task-definition"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"
  container_definitions = <<DEFINITION
  [
    {
      "name": "fe-container",
      "image": "${var.frontend_ecr_image_url}",
      "environment": [
        {
          "name": "API_BASE_URL",
          "value": "https://${var.domain_name}/ecommerce/api/v1"
        }
      ],
      "cpu": 512,
      "memory": 1024,
      "portMappings": [
        {
          "containerPort": 4200,
          "hostPort": 4200,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.frontend_log_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "final-assignment"
        }
      }
    }
  ]
  DEFINITION
}


resource "aws_ecs_service" "frontend_service" {
  name            = "final-assignment-fe"
  network_configuration {
    subnets = var.ecs_subnet_ids
    security_groups = var.ecs_security_group_ids
    assign_public_ip = true
  }
  cluster         = aws_ecs_cluster.final-assignment_ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "fe-container"
    container_port   = 4200
  }

}

####### Backend ######
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "ecs/final-assignment-be"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "backend-task-definition"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"
  container_definitions = <<DEFINITION
  [
    {
      "name": "java-container",
      "image": "${var.backend_ecr_image_url}",
      "cpu": 512,
      "memory": 1024,
      "environment": [
        {
          "name": "MYSQL_USERNAME",
          "value": "${var.rds_username}"
        }
      ],
      "secrets": [
        {
          "name": "SPRING_DATASOURCE_URL",
          "valueFrom": "${var.rds_connection_string_secret_arn}"
        },
        {
          "name": "MYSQL_ROOT_PASSWORD",
          "valueFrom": "${var.rds_password_secret_arn}"  
        }
      ],
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.backend_log_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "final-assignment"
        }
      }
    }
  ]
  DEFINITION
}


resource "aws_ecs_service" "backend_service" {
  name            = "final-assignment-be"
  network_configuration {
    subnets = var.ecs_subnet_ids
    security_groups = var.ecs_security_group_ids
    assign_public_ip = true
  }
  cluster         = aws_ecs_cluster.final-assignment_ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "java-container"
    container_port   = 8080
  }

}