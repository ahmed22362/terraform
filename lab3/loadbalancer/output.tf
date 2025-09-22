output "lb_private_dns" {
    value = aws_lb.lab3_private_lb.dns_name
}
output "lb_public_dns" {
    value = aws_lb.lab3_public_lb.dns_name
  
}
