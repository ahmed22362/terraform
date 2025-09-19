resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "lap2-main-vpc"
  }
  region = var.region
}


resource "aws_security_group" "lap2_public_sg" {
  name = "public-security-group"
  vpc_id = aws_vpc.main_vpc.id
  region = var.region

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lap2-security-group"
  }
}
resource "aws_security_group" "lap2_private_sg" {
  name        = "private-sg"
  vpc_id      = aws_vpc.main_vpc.id
  region      = var.region
  ingress {
    description = "Allow HTTP traffic from Public SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lap2_public_sg.id]
  }

  ingress {
    description = "Allow SSH traffic  from Public SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.lap2_public_sg.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-security-group"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.subnet_public_cidr
  region = var.region
  tags = {
    Name = "lap2-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.subnet_private_cidr
  region = var.region
  tags = {
    Name = "lap2-private-subnet"
  }
}
resource "aws_eip" "lap2_eip" {
  region = var.region
    domain = "vpc"
  tags = {
    Name = "lap2-eip"
  }
}
resource "aws_nat_gateway" "lap2_nat" {
  region = var.region
  allocation_id = aws_eip.lap2_eip.id
  subnet_id    = aws_subnet.public_subnet.id

  tags = {
    Name = "lap2-nat-gateway"
  }
}
resource "aws_internet_gateway" "lap2_ig" {
  vpc_id = aws_vpc.main_vpc.id
  region = var.region
  tags = {
    Name = "lap2-ig"
  }
}

resource "aws_route_table" "lap2_public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  region = var.region
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lap2_ig.id
  }
  tags = {
    Name = "lap2-route-table"
  }
}

resource "aws_route_table" "lap2_private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  region = var.region
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lap2_nat.id
  }
  tags = { Name = "lab2-private-rt" }

}
resource "aws_route_table_association" "public_subnet" {
  region = var.region
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.lap2_public_route_table.id
}

resource "aws_route_table_association" "private_subnet" {
  region = var.region
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.lap2_private_route_table.id
}