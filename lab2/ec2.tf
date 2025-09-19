data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  region      = var.region
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "lap2_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.lap2_public_sg.id] 
  associate_public_ip_address = true
  tags = {
    Name = "lap2-ec2-instance"
  }
  region = var.region
}
resource "aws_instance" "private_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id  
  vpc_security_group_ids = [aws_security_group.lap2_private_sg.id]
  user_data = var.user_data
  tags = { Name = "lab2-private-ec2" }

  region = var.region
}