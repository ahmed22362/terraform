provider "aws" {
    
  shared_config_files = ["conf"]
  shared_credentials_files = [ "creds" ]
  region = "us-east-1"
}