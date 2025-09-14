# Basic Example - Azure Storage Container

This example demonstrates how to use the Azure Storage Container module with basic configuration.

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - Set the storage account name and resource group
   - Update tags as needed

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What This Example Creates

- A storage container with private access
- Custom metadata for organization
- Proper tagging following ZRR standards
- Basic container configuration

## Prerequisites

- Azure Storage Account must already exist
- Appropriate permissions to create containers in the storage account
- Azure CLI or Service Principal authentication configured

## Outputs

This example will output:
- Container ID and name
- Container URL for access
- Security features summary