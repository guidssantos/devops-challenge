terraform {
  required_providers {
    aws = {source = "hashicorp/aws", version = "5.17.0"}
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

terraform {
    backend "s3" {
      bucket = "terraform-state-devops-v4"
      key = "terraform.tfstate"
      region = "us-east-1"
      dynamodb_table = "tfstate"
        encrypt        = true
    }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC ---

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
    azs_count = 3
    azs_names = data.aws_availability_zones.available.names
}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {Name = "${var.name}-vpc"} 
}

resource "aws_subnet" "public" {
  count = local.azs_count
  vpc_id = aws_vpc.main.id
  availability_zone = local.azs_names[count.index]
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)  
  map_public_ip_on_launch = true
  tags = {Name = "${var.name}-public-${local.azs_names[count.index]}"}
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {Name = "${var.name}-igw"}
}

resource "aws_eip" "main" {
  count = local.azs_count
  depends_on = [ aws_internet_gateway.main ]
  tags = {Name = "${var.name}-eip-${local.azs_names[count.index]}"}
}

#  --- Public Route Table ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {Name = "${var.name}-rtb-public"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = local.azs_count
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Instance ---

resource "aws_instance" "instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  tags = {
    Name = "${var.name}-instance"
  }
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.public[0].id
}


output "instance_ip" {
  value = aws_instance.instance.public_ip
}
