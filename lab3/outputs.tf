output "public_load_balancer_dns" {
  description = "Public Load Balancer DNS name"
  value       = module.loadbalancer.lb_public_dns
}

output "private_load_balancer_dns" {
  description = "Private Load Balancer DNS name"
  value       = module.loadbalancer.lb_private_dns
}

output "public_instance_ips" {
  description = "Public instance IP addresses"
  value       = module.instances.public_instance_ip
}

output "private_instance_ips" {
  description = "Private instance IP addresses"
  value       = module.instances.private_instance_ips
}