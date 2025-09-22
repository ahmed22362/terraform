variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  
}