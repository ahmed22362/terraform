variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "subnet_public_cidr" {
  type = string
  default = "10.0.0.0/24"
}
variable "subnet_private_cidr" {
  type = string
  default = "10.0.1.0/24"
}
variable "instance_type" { default = "t2.micro" }
variable "ami_id" { default = "ami-0ca4d5db4872d0c28" } 
variable "key_name" {
  type = string
  default = "my-key"
}
variable "my_ip" {
  type = string
}
variable "lap2_region" {
  type = string
  default = "us-east-2"
}
variable "user_data" {
  description = "The user data script to configure the instance"
  type        = string
}
variable "region" {
  description = "The AWS region to deploy resources"
  type = string
  default = "us-east-2"
 
}