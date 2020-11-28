resource "aws_ecs_cluster" "test_cluster" {
  name  = "test"

  tags = {
    Terraform = "mizu0/terraform"
  }
}

resource "aws_ecs_task_definition" "test_taskd" {
  family                   = "test_taskd"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions/dummy.json")

  # task_definition は初回作成以降は別リポジトリ&github actions を利用して更新
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "test_service" {
  name                              = "test_service"
  cluster                           = aws_ecs_cluster.test_cluster.arn
  task_definition                   = aws_ecs_task_definition.test_taskd.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_test_sg.id]

    subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_blue.arn
    container_name   = "server"
    container_port   = 8000
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }


  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }

  tags = {
    Terraform = "mizu0/terraform"
  }
  depends_on = [aws_ecs_task_definition.test_taskd]
}

resource "aws_security_group" "ecs_test_sg" {
  name        = "ecs-test-sg"
  description = "ecs-test-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "server port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-test-sg"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_cloudwatch_log_group" "test-server" {
  name = "/ecs/test-server"

  retention_in_days = 3
}