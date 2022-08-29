resource "aws_security_group" "sglb" {
  name        = "sglb"
  description = "Allow 80,443,22"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_code}-sglb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "sample_tg" {
  name                          = "lb-tg-1"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.main.id
  load_balancing_algorithm_type = "round_robin"
  deregistration_delay          = 60

  stickiness {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = 60
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "appln-lb" {

  name               = "appln-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sglb.id]
  subnets            = [aws_subnet.public[count.index].id]

  enable_deletion_protection = false

  tags = {
    Environment = "${var.env_code}-appln-lb"
  }
}

resource "aws_lb_listener" "listner" {
  
  count = 2
  
  load_balancer_arn = aws_lb.appln-lb[count.index].id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = " Site Not Found"
      status_code  = "200"
    }
  }

  depends_on = [aws_lb.appln-lb]
}

resource "aws_lb_listener_rule" "rule" {
  
  listener_arn = aws_lb_listener.listner[count.index].id
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_tg.arn
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}
