output "public_security_group_id" {
  value = aws_security_group.lab3_public_sg.id
}
output "private_security_group_id" {
  value = aws_security_group.lab3_private_sg.id
}
output "private_lb_security_group_id" {
  value = aws_security_group.lab3_private_lb_sg.id
}
output "private_instance_ips" {
  value = aws_instance.lab3_private_instance.*.private_ip
}
output "public_instance_ids" {
  value = aws_instance.lab3_public_instance.*.id
}
output "private_instance_ids" {
  value = aws_instance.lab3_private_instance.*.id
}
output "public_instance_ip" {
  value = aws_instance.lab3_public_instance.*.public_ip
}