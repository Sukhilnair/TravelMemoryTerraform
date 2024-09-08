terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "travelmemory" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "travelMemory-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.travelmemory.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.travelmemory.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.travelmemory.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.travelmemory.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.travelmemory.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH-SG"
  }
}

resource "aws_security_group" "backend" {
  vpc_id = aws_vpc.travelmemory.id

  ingress {
    description = "Allow Backend port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BACKEND-SG"
  }
}

resource "aws_security_group" "frontend" {
  vpc_id = aws_vpc.travelmemory.id

  ingress {
    description = "Allow frontend port"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-SG"
  }
}

resource "tls_private_key" "my_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "travelmemory-keypair" {
  key_name   = "travelmemory-ec2-key"
  public_key = tls_private_key.my_tls_key.public_key_openssh
}


resource "aws_s3_bucket" "mys3bucket" {
  bucket = var.bucketname
  tags = {
    Name        = "travelmemorysukhil07092024"
    Environment = "Dev"
  }
}

resource "aws_instance" "travelmemoryec2" {
  ami           = "ami-056a29f2eddc40520"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.travelmemory-keypair.key_name

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.backend.id,
    aws_security_group.frontend.id
  ]

  user_data = file("./userdata.sh")

  tags = {
    Name = "travelMemory-sukhil"
  }
}

