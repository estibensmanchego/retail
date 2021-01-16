terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "clients"
  region  = "us-east-1"
}

resource "tls_private_key" "clients_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "clients_generated_key" {
  key_name   = "clients_key_iac"
  public_key = tls_private_key.clients_private_key.public_key_openssh
}

resource "null_resource" "get_keys" {

  provisioner "local-exec" {
    command     = "echo '${tls_private_key.clients_private_key.public_key_openssh}' > ./public_key.rsa"
  }

  provisioner "local-exec" {
    command     = "echo '${tls_private_key.clients_private_key.private_key_pem}' > ./private_key.pem"
  }

}

resource "aws_vpc" "clients_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "clients_vpc"
  }
}

resource "aws_subnet" "clients_subnet_a" {
  vpc_id     = aws_vpc.clients_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "clients-subnet-a"
  }
}

resource "aws_subnet" "clients_subnet_b" {
  vpc_id     = aws_vpc.clients_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "clients-subnet-b"
  }
}

resource "aws_subnet" "clients_subnet_c" {
  vpc_id     = aws_vpc.clients_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "clients-subnet-c"
  }
}

resource "aws_internet_gateway" "clients_internet_gateway" {
  vpc_id = aws_vpc.clients_vpc.id
  tags = {
    Name = "clients-internet-gateway"
  }
}

resource "aws_route_table" "clients_route_table" {
  vpc_id = aws_vpc.clients_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.clients_internet_gateway.id
  }
}

resource "aws_main_route_table_association" "clients_main_route_table" {
  vpc_id         = aws_vpc.clients_vpc.id
  route_table_id = aws_route_table.clients_route_table.id
}

resource "aws_security_group" "clients_sg" {
  name = "clients-security-group"
  vpc_id      = aws_vpc.clients_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = [aws_vpc.clients_vpc.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "clients_net_int" {
  subnet_id       = aws_subnet.clients_subnet_a.id
  private_ips     = ["10.0.0.5"]
  security_groups = [aws_security_group.clients_sg.id]
}

resource "aws_eip" "clients_eip" {
  instance = aws_instance.clients.id
  vpc      = true
}

resource "aws_instance" "clients" {
  ami           = "ami-04d29b6f966df1537"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.clients_generated_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.clients_net_int.id
    device_index         = 0
  }

  tags = {
    Name = "clients-dev"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.clients.id
  allocation_id = aws_eip.clients_eip.id
}
