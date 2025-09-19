output "ec2_public_ip" {
  value = aws_instance.lap2_ec2.public_ip
}
output "ec2_private_ip" {
  value = aws_instance.private_ec2.private_ip
}