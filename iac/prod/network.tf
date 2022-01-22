## VPC
resource "aws_vpc" "foundry" {
  cidr_block            = var.cidr-vpc
  enable_dns_hostnames  = true
}

## SECURITY GROUPS
resource "aws_security_group" "foundry-sg" {
  name        = "foundry-sg"
  description = "Allow communication to and from Foundry"
  vpc_id = aws_vpc.foundry.id

  # foundry tcp
  ingress {
    from_port   = var.foundry-port
    to_port     = var.foundry-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # foundry udp
  ingress {
    from_port   = var.foundry-port
    to_port     = var.foundry-port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # secure foundry tcp
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # secure foundry udp
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
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
}

resource "aws_security_group" "foundry-efs" {
  name    = "foundry-efs-sg"
  vpc_id  = aws_vpc.foundry.id

  ingress {
    from_port       = var.foundry-port
    to_port         = var.foundry-port
    protocol        = "tcp"
    security_groups = [
      aws_security_group.foundry-sg.id
    ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [
      aws_security_group.foundry-sg.id
    ]
  }
}

## SUBNETS
resource "aws_subnet" "public" {
  cidr_block        = "${cidrsubnet(aws_vpc.foundry.cidr_block, 4, 8)}"
  vpc_id            = aws_vpc.foundry.id
  availability_zone = var.availability-zone
}

resource "aws_subnet" "public2" {
  cidr_block        = "${cidrsubnet(aws_vpc.foundry.cidr_block, 12, 8)}"
  vpc_id            = aws_vpc.foundry.id
  availability_zone = var.availability-zone2
}

/*
resource "aws_subnet" "efs" {
  cidr_block        = "${cidrsubnet(aws_vpc.foundry.cidr_block, 8, 8)}"
  vpc_id            = aws_vpc.foundry.id
  availability_zone = var.availability-zone
}
*/

## IG & ROUTES
resource "aws_internet_gateway" "foundry" {
  vpc_id = aws_vpc.foundry.id
}

resource "aws_route_table" "foundry-public" {
  vpc_id = aws_vpc.foundry.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.foundry.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.foundry.id
  }
}

resource "aws_route_table_association" "foundry" {
  subnet_id       = aws_subnet.public.id
  route_table_id = aws_route_table.foundry-public.id
}

resource "aws_route_table_association" "foundry2" {
  subnet_id       = aws_subnet.public2.id
  route_table_id  = aws_route_table.foundry-public.id
}

## ELB
