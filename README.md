# Deploy_VPC_using_Terraform
manually creating an S3 Bucket and dynamoDB table and configuring terraform provider to use it as a remote state storage

#Create a LoadBalancer
Load balancer should live in public subnets
Instance should be redeployed to a private subnet
Load balancer should have a separate security group
