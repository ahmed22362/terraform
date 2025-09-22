provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["conf"]
  shared_credentials_files = ["creds"]
}