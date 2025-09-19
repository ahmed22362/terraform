# Terraform Projects

This repository contains Terraform configurations for infrastructure as code.

## Structure

- `lap1/` - First lab/project containing basic Terraform configurations
- `lap2/` - Second lab/project with EC2 and other AWS resources

## Prerequisites

- Terraform installed
- AWS CLI configured
- Valid AWS credentials

## Usage

Navigate to the desired lab directory and run:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

Make sure to configure your AWS provider with appropriate credentials and region settings.

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```
