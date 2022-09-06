env_code     = "main"
vpc_cidr     = "10.0.0.0/16"
public_cidr  = ["10.0.0.0/24", "10.0.1.0/24"]
private_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
ami          = "ami-05fa00d4c63e32376"
type         = "t2.micro"
asg_count    = 2
