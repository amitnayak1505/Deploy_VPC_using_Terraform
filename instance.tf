data "aws_ami" "linuxinstance" {
  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}


resource "aws_instance" "public" {
  ami                         = data.aws_ami.linuxinstance.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "devpair"
  vpc_security_group_ids      = [aws_security_group.public.id]
  
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  yum update -y
  yum install httpd -y
  echo "*** Completed Installing apache2"
  systemctl start httpd
  systemctl enable httpd
  echo "<html><body><h1>Hi there</h1></body></html>" > /var/www/html/index.html
  EOF
  
  subnet_id                   = aws_subnet.public[1].id
 tags = {
   Name = "${var.env_code}-public"
 }
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Inbound rules from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]

  }
  ingress {
    description = "Inbound rules from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block, "49.207.195.192/32"]
  }

  ingress {
    description = "Inbound rules from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block, "49.207.195.192/32"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}
