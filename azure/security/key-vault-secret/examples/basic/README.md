# Basic Example - Azure Key Vault Secret

This example demonstrates how to use the Azure Key Vault Secret module with basic configuration.

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - Set the Key Vault name and resource group
   - Provide the secret value
   - Update tags as needed

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What This Example Creates

- A Key Vault secret with the specified name and value
- Proper tagging following ZRR standards
- Content type specification
- Expiration date configuration

## Prerequisites

- Azure Key Vault must already exist
- Appropriate permissions to create secrets in the Key Vault
- Azure CLI or Service Principal authentication configured

## Outputs

This example will output:
- Secret ID
- Secret version
- Key Vault ID used