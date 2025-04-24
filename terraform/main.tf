provider "aws" {
  region = "us-east-1"
}

# Default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for ECS (allow traffic on 1337)
resource "aws_security_group" "ecs_sg" {
  name        = "strapi-ecs-sg"
  description = "Allow traffic for ECS containers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
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

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "strapi-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group for ECS service (port 1337)
resource "aws_lb_target_group" "strapi_tg" {
  name        = "strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"  # Accept 200-399 status codes
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener (port 80 → 1337)
resource "aws_lb_listener" "alb_listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

# ALB Listener (port 1337 → 1337)
resource "aws_lb_listener" "alb_listener_1337" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 1337
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition (using ECR image passed as variable)
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.ecr_image
      essential = true
      portMappings = [{
        containerPort = 1337
        hostPort      = 1337
        protocol      = "tcp"
      }]
    }
  ])
}

# ECS Service with Load Balancer
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.alb_listener_80, aws_lb_listener.alb_listener_1337]
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "strapi_log_group" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

# ECS Task Definition with Log Configuration
resource "aws_ecs_task_definition" "strapi_task_with_logging" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.ecr_image
      essential = true
      portMappings = [{
        containerPort = 1337
        hostPort      = 1337
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs/strapi"
        }
      }
    }
  ])
}

# CloudWatch Metrics Collection (Optional, for ECS)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name                = "High-CPU-Utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Alarm when CPU exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name                = "High-Memory-Utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Alarm when memory exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
}
resource "aws_cloudwatch_metric_alarm" "ecs_network_in" {
  alarm_name          = "strapi-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkBytesIn"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000  # 100MB
  alarm_description   = "High incoming traffic"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_network_out" {
  alarm_name          = "strapi-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkBytesOut"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000  # 100MB
  alarm_description   = "High outgoing traffic"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {
  alarm_name          = "strapi-task-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No running ECS tasks"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
}