project_name = "tutorial-vpc"
environment  = "development"
aws_region   = "eu-west-1"
ami_id       = "ami-069216845f57c35fc"
vpc_cidr     = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
key_pair_name = "ubuntuKey-eu-west-1"
