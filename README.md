# NGINX Reverse Proxy with Let's Encrypt SSL (Terraform & Ansible)

Automates deployment of an NGINX reverse proxy with Let's Encrypt SSL certificates on AWS, using Terraform for infrastructure and Ansible for configuration.

## Features
- AWS EC2 infrastructure provisioning with Terraform/OpenTofu
- NGINX reverse proxy with automatic SSL via Let's Encrypt
- Docker container deployment of sample web application
- Secure GitHub PAT storage in AWS SSM
- Automated SSL certificate renewal

## Prerequisites
- AWS account and configured AWS CLI
- SSH key pair in AWS
- Domain name
- GitHub PAT with repo scope
- OpenTofu CLI installed

## Quick Start
1. Clone repository
2. Update GitHub PAT in `main.tf`
3. Run:

make init
make plan
make apply


## Available Commands

make init      # Initialize Terraform
make plan      # Preview changes
make apply     # Deploy infrastructure
make destroy   # Remove infrastructure
make clean     # Clean local files


## Files
- `main.tf` - AWS infrastructure configuration
- `playbook.yml` - Ansible configuration
- `user_data.yml` - Instance bootstrap script
- `Makefile` - Automation commands

## Security Notes
- Default security group allows ports 22, 80, 443 from anywhere
- Update domain name and email in `playbook.yml`
- Manage GitHub PAT securely
