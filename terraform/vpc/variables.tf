variable "project_name" {
  description = "Project name for tags"
  type        = string
  default     = "tutorial-vpc"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "web_port" {
  description = "Port that the web servers will listen on"
  type        = number
  default     = 80
}

variable "tg_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "tg_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "key_pair_name" {
  description = "EC2 key pair name to attach to instances"
  type        = string
  default     = "ubuntuKey"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to run"
  type        = number
  default     = 2
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
}

variable "create_https_listener" {
  description = "Create HTTPS listener after certificate is validated"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "FQDN to use for the ALB certificate (e.g. page.sodeep.link)"
  type        = string
  default     = "page.sodeep.link"
}

variable "ami_id" {
  description = "AMI id to use for web servers"
  type        = string
  default     = "ami-06799520353881127"
}