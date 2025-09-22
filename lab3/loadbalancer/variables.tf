variable "public_subnets_id" {
  description = "The subnet IDs to launch the public load balancer in"
  type        = list(string)
}
variable "private_subnets_id" {
  description = "The subnet IDs to launch the private load balancer in"
  type        = list(string)
  
}
variable "lab3_vpc_id" {
  description = "The VPC ID where the load balancer will be created"
  type        = string
  
}
variable "public_instance_ids" {
  description = "The IDs of the public instances to attach to the load balancer"
  type        = list(string)
  
}
variable "private_instance_ids" {
  description = "The IDs of the private instances to attach to the load balancer"
  type        = list(string)
  
}
variable "lab3_public_sg" {
  description = "The security group ID for the public instances"
  type        = string 
}
variable "lab3_private_sg" {
  description = "The security group for the private instances"
  type        = string 
}
