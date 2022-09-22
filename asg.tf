data "aws_ami" "linuxinstance" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

resource "aws_launch_configuration" "ec2" {
  image_id             = data.aws_ami.linuxinstance.id
  instance_type        = var.type
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  security_groups      = [aws_security_group.public.id]
  user_data            = file("userdata1.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  count                = 2
  subnets              = [aws_subnet.public[count.index].id]
  launch_configuration = aws_launch_configuration.ec2.id
  health_check_type    = "EC2"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 2
  target_group_arns    = [aws_lb_target_group.sample_tg.arn]
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "Asg"
  }

  lifecycle {
    create_before_destroy = true
  }
}


