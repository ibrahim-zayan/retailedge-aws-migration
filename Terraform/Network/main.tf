# =========================
# VPC
# =========================

resource "aws_vpc" "retailedge" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "retailedge-vpc"
  }
}


# =========================
# Internet Gateway
# =========================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.retailedge.id

  tags = {
    Name = "retailedge-igw"
  }
}


# =========================
# Public Subnets
# =========================

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "retailedge-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "retailedge-public-b"
  }
}


# =========================
# Private App Subnets
# =========================

resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "retailedge-app-a"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "retailedge-app-b"
  }
}


# =========================
# Private DB Subnets
# =========================

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "retailedge-db-a"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.retailedge.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "retailedge-db-b"
  }
}


# =========================
# Elastic IPs for NAT
# =========================

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "retailedge-nat-eip-a"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = {
    Name = "retailedge-nat-eip-b"
  }
}


# =========================
# NAT Gateways
# =========================

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "retailedge-nat-a"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "retailedge-nat-b"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# =========================
# Public Route Table
# =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.retailedge.id

  tags = {
    Name = "retailedge-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


# =========================
# Public Route Associations
# =========================

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}


# =========================
# Private App Route Tables
# =========================

resource "aws_route_table" "app_a" {
  vpc_id = aws_vpc.retailedge.id

  tags = {
    Name = "retailedge-app-rt-a"
  }
}

resource "aws_route_table" "app_b" {
  vpc_id = aws_vpc.retailedge.id

  tags = {
    Name = "retailedge-app-rt-b"
  }
}


resource "aws_route" "app_a_internet" {
  route_table_id         = aws_route_table.app_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "app_b_internet" {
  route_table_id         = aws_route_table.app_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}


# =========================
# App Route Associations
# =========================

resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.app_a.id
}

resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.app_b.id
}


# =========================
# Private DB Route Table
# =========================

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.retailedge.id

  tags = {
    Name = "retailedge-db-rt"
  }
}


# =========================
# DB Route Associations
# =========================

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.db.id
}
# =========================
# ALB Security Group
# =========================

resource "aws_security_group" "alb_sg" {
  name   = "retailedge-alb-sg"
  vpc_id = aws_vpc.retailedge.id

  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from Internet"
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

  tags = {
    Name = "retailedge-alb-sg"
  }
}


# =========================
# App Security Group
# =========================

resource "aws_security_group" "app_sg" {
  name   = "retailedge-app-sg"
  vpc_id = aws_vpc.retailedge.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "retailedge-app-sg"
  }
}


# =========================
# DB Security Group
# =========================

resource "aws_security_group" "db_sg" {
  name   = "retailedge-db-sg"
  vpc_id = aws_vpc.retailedge.id

  ingress {
    description     = "Allow MySQL from App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "retailedge-db-sg"
  }
}