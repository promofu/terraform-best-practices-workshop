# Sub-tasks:
# 1. Create a single AWS EC2 instance (web)
# 2. Add variables for all required arguments
# 3. Add data source to fetch ID of default security group, subnet and ID of Amazon linux AMI

terraform {
  required_version = ">= 0.12.6, < 0.14"

  required_providers {
    aws = ">= 2.46, < 4.0"
  }
}

provider "aws" {
  region = "eu-west-1"
}

############
# Variables
############
variable "name" {
  description = "Name of EC2 instance"
  default = "JG Test (user5)"
}

variable "instance_type" {
  description = "EC2 instance type"
  default = "t2.micro"
}

######################################################################
# Data sources - VPC, subnets, default security group and AMI details
######################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Finding a Linux AMI: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
# AWS CLI: aws ec2 describe-images --filters Name=name,Values="amzn-ami-hvm-*-x86_64-gp2"
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
}

############
# Resources
############
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.image_id
  instance_type = var.instance_type
  subnet_id     = element(tolist(data.aws_subnet_ids.all.ids), 0)

  tags = {
    Name = var.name
  }
}

##########
# Outputs
##########
output "public_ip" {
  value = aws_instance.web.public_ip
}
