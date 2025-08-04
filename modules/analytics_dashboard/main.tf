variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "dashboard_image" {
  description = "Container image for the analytics dashboard"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

resource "aws_ecs_cluster" "dashboard" {
  name = "analytics-dashboard-${var.environment}"
}

resource "aws_iam_role" "ecs_task_exec" {
  name = "ecsTaskExecutionRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "dashboard" {
  family                   = "analytics-dashboard"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  container_definitions = jsonencode([
    {
      name      = "dashboard"
      image     = var.dashboard_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_security_group" "dashboard" {
  name        = "dashboard-sg-${var.environment}"
  description = "Allow HTTP traffic to dashboard"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "dashboard-alb-sg-${var.environment}"
  description = "Allow HTTP to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "dashboard" {
  name               = "dashboard-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
}

# Target Group
resource "aws_lb_target_group" "dashboard" {
  name     = "dashboard-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener
resource "aws_lb_listener" "dashboard" {
  load_balancer_arn = aws_lb.dashboard.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }
}

# Update ECS Service to use ALB
resource "aws_ecs_service" "dashboard" {
  name            = "analytics-dashboard"
  cluster         = aws_ecs_cluster.dashboard.id
  task_definition = aws_ecs_task_definition.dashboard.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.dashboard.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.dashboard.arn
    container_name   = "dashboard"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.dashboard]
}

output "dashboard_url" {
  description = "URL of the analytics dashboard"
value       = "http://${aws_lb.dashboard.dns_name}"
}

output "dashboard_alb_dns" {
  description = "DNS name for the analytics dashboard ALB"
  value       = aws_lb.dashboard.dns_name
}

output "dashboard_task_definition_arn" {
  description = "ARN of the ECS task definition for the analytics dashboard"
  value       = aws_ecs_task_definition.dashboard.arn
}
output "dashboard_security_group_id" {
  description = "Security group ID for the analytics dashboard"
  value       = aws_security_group.dashboard.id
}
output "dashboard_alb_security_group_id" {
  description = "Security group ID for the analytics dashboard ALB"
  value       = aws_security_group.alb.id
}
output "dashboard_cluster_name" {
  description = "Name of the ECS cluster for the analytics dashboard"
  value       = aws_ecs_cluster.dashboard.name
}
output "dashboard_service_name" {
  description = "Name of the ECS service for the analytics dashboard"
  value       = aws_ecs_service.dashboard.name
}
output "dashboard_task_role_arn" {
  description = "ARN of the IAM role for the ECS task"
  value       = aws_iam_role.ecs_task_exec.arn
}
output "dashboard_task_execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_exec.arn
}
