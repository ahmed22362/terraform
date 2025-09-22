variable "backend_bucket_name" {
  description = "The name of the S3 bucket for Terraform backend"
  type        = string
  default     = "my-terraform-backend-bucket-2025"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "instance_type" {
  description = "Type of instance to use"
  type        = string
  default     = "t2.micro"
}
variable "key_path" {
  description = "The path to the private key file for SSH access"
  type        = string
  default     = "~/.aws/labs_key.pem"
}
variable "ssh_key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "labs_key"
}
variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}