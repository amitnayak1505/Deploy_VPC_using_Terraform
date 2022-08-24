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
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
   cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
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
    Name = "sglb"
  }
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "appln-lb" {
  count = length(var.public_cidr)
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

  load_balancer_arn =aws_lb.appln-lb.id
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

  depends_on = [aws_lb.appln-lb ]
}

resource "aws_lb_listener_rule" "rule" {

  listener_arn = aws_lb_listener.listner.id
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
