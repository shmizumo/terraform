resource "aws_security_group" "ecs_alb_sg" {
  name        = "ecs-alb-sg"
  description = "Allow http inbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
  }

  # codedeploy の AfterAllowTestTraffic Hook用
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.outputs.nat_gateway_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-alb-sg"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_lb" "ecs_bluegreen" {
  name                       = "ecs-bluegreen-test-lb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60

  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets = data.terraform_remote_state.vpc.outputs.public_subnets

  tags = {
    Terraform = "mizu0/terraform"
  }
}


resource "aws_lb_listener" "ecs_bluegreen" {
  load_balancer_arn = aws_lb.ecs_bluegreen.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Temporarily Unavailable"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "ecs_bluegreen_test" {
  load_balancer_arn = aws_lb.ecs_bluegreen.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Temporarily Unavailable"
      status_code  = "503"
    }
  }
}

resource "aws_lb_target_group" "ecs_blue" {
  name                 = "ecs-blue-tg"
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 30

  health_check {
    path                = "/hello"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Terraform = "mizu0/terraform"
  }

  depends_on = [aws_lb.ecs_bluegreen]
}

resource "aws_lb_target_group" "ecs_green" {
  name                 = "ecs-green-tg"
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 30

  health_check {
    path                = "/hello"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Terraform = "mizu0/terraform"
  }

  depends_on = [aws_lb.ecs_bluegreen]
}

resource "aws_lb_listener_rule" "ecs_bluegreen" {
  listener_arn = aws_lb_listener.ecs_bluegreen.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_blue.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    # actionの状態は無視
    ignore_changes = [
      action
    ]
  }
}

resource "aws_lb_listener_rule" "ecs_bluegreen_test" {
  listener_arn = aws_lb_listener.ecs_bluegreen_test.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_green.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    # actionの状態は無視
    ignore_changes = [
      action
    ]
  }
}