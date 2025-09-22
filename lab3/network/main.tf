resource "aws_vpc" "lab3_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "lab3_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id            = aws_vpc.lab3_vpc.id
  cidr_block       = cidrsubnet(var.vpc_cidr, 8, count.index)
  tags = {
    Name = "public_subnet-${count.index}"
  } 
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]
}
resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id            = aws_vpc.lab3_vpc.id
  cidr_block       = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  tags = {
    Name = "private_subnet-${count.index}"
  } 
  availability_zone = var.availability_zones[count.index]
}
resource "aws_internet_gateway" "lab3_igw" {
  vpc_id = aws_vpc.lab3_vpc.id
  tags = {
    Name = "lab3_igw"
  }
}
resource "aws_eip" "lap3_eip" {
    domain = "vpc"
  tags = {
    Name = "lab3-eip"
  }
  
}
resource "aws_nat_gateway" "lab3_nat" {
  allocation_id = aws_eip.lap3_eip.id
  subnet_id    = aws_subnet.public_subnet[0].id
}
resource "aws_route_table" "lab3_public_rt" {
  vpc_id = aws_vpc.lab3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab3_igw.id
  }
  tags = {
    Name = "lab3_public_rt"
  }
}
resource "aws_route_table" "lab3_private_rt" {
  vpc_id = aws_vpc.lab3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab3_nat.id
  }
  tags = {
    Name = "lab3_private_rt"
  }
}
resource "aws_route_table_association" "lab3_public_rt_assoc" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.lab3_public_rt.id
}
resource "aws_route_table_association" "lab3_private_rt_assoc" {
  count = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.lab3_private_rt.id
}