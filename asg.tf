resource "aws_launch_configuration" "ec2" {
  image_id        = var.ami
  instance_type   = var.type
  security_groups = [aws_security_group.public.id]
  user_data       = file("userdata1.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.ec2.id
  health_check_type    = "EC2"
  min_size             = var.asg_count
  max_size             = var.asg_count
  desired_capacity     = var.asg_count
  vpc_zone_identifier  = [aws_subnet.public[count.index].id]
  target_group_arns    = [aws_lb_target_group.sample_tg.arn]
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "Asg"
    Enviroment          = "${var.env_code}-asg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
