resource "aws_vpc" "lap_subnet" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "lab1-vpc"
  }
}
resource "aws_subnet" "lap_subnet" {
  vpc_id     = aws_vpc.lap_subnet.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lap_subnet.id
}


resource "aws_route_table" "lap_route_table" {
  vpc_id = aws_vpc.lap_subnet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lap_subnet.id
  route_table_id = aws_route_table.lap_route_table.id
}


resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.lap_subnet.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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


resource "aws_instance" "web" {
  ami           = "ami-0634f3c109dcdc659"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.lap_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name = "iti"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              echo "Hello from Terraform Apache!" > /var/www/html/index.html
              EOF
}