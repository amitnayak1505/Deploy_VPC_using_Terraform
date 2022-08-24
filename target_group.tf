resource "aws_lb_target_group" "sample_tg" {
  name     = "lb-sample-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
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
