variable "instance_type" {
  description = "Type of instance to use"
  type        = string 
}
variable "public_subnet_ids" {
  description = "The public subnet IDs to launch public instances in"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "The private subnet IDs to launch private instances in"
  type        = list(string)
}
variable "lab3_vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}
variable "lab3_vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "private_lb_dns_name" {
  description = "The DNS name of the private load balancer"
  type        = string
  default     = ""
}
variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
  
}
variable "key_path" {
  description = "The path to the private key file for SSH access"
  type        = string
}