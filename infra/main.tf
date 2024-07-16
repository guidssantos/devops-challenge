terraform {
  required_providers {
    aws = {source = "hashicorp/aws", version = "5.17.0"}
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}


output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = "${aws_instance.instance.public_ip}"
}


# --- VPC ---

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {Name = "${var.name}-vpc"} 
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.name}-public-subnet"
  }
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_eip" "main" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-eip"
  }
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
  subnet_id      = aws_subnet.public.id
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
  subnet_id = aws_subnet.public.id
}


