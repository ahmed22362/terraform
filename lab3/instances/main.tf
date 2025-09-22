data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
}
resource "aws_security_group" "lab3_public_sg" {
  vpc_id = var.lab3_vpc_id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
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
    Name = "lab3_public_sg"
  }
}
resource "aws_security_group" "lab3_private_sg" {
  vpc_id = var.lab3_vpc_id
  ingress {
    description = "Allow SSH traffic from public SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.lab3_public_sg.id]
  }
  ingress {
    description = "Allow SSH traffic from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.188.235.152/32"]  # Your specific IP
  }
  ingress {
    description = "Allow HTTP traffic from public SG"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lab3_public_sg.id]
  }
  ingress {
    description = "Allow HTTP traffic from private LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lab3_private_lb_sg.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab3_private_sg"
  }
}

# Security group for private load balancer
resource "aws_security_group" "lab3_private_lb_sg" {
  vpc_id = var.lab3_vpc_id
  name_prefix = "lab3-private-lb-sg"
  
  ingress {
    description = "Allow HTTP traffic from public instances"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lab3_public_sg.id]
  }
  
  ingress {
    description = "Allow HTTP traffic from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.lab3_vpc_cidr]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.lab3_vpc_cidr]
  }

  tags = {
    Name = "lab3_private_lb_sg"
  }
}
resource "aws_instance" "lab3_public_instance" {
  count = 2
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[count.index]
  tags = {
    Name = "lab3_public_instance"
  }
  associate_public_ip_address = true  
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.lab3_public_sg.id]
   provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      # "echo 'proxy_pass http://${var.private_lb_dns_name};' | sudo tee /etc/nginx/conf.d/proxy.conf",
      # "sudo systemctl enable nginx",
      # "sudo systemctl restart nginx"
    ]
      connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = self.public_ip
  }
    }
  provisioner "local-exec" {
    command = "echo 'Public Instance ${count.index} - ${self.public_ip}' >> ../instances_info.txt"
  }
  
}
resource "aws_instance" "lab3_private_instance" {
  count = 2
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.lab3_private_sg.id]
  key_name               = var.ssh_key_name
  tags = {
    Name = "lab3_private_instance"
  }
  associate_public_ip_address = false
    provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "echo '<h1>Hello from Private Apache $(hostname)</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
      connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = self.private_ip
      # This is jump/bastion host configuration
    bastion_host        = aws_instance.lab3_public_instance[count.index].public_ip
    bastion_user        = "ec2-user"
    bastion_private_key = file(var.key_path)
  }
    }
  provisioner "local-exec" {
    command = "echo 'Private Instance ${count.index} - ${self.private_ip}' >> ../instances_info.txt"
  }
}