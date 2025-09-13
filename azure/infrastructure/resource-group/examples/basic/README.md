# Basic Resource Group Example

This example demonstrates how to create a simple Azure Resource Group using the ZRR Terraform module.

## Prerequisites

- Azure subscription
- Terraform >= 1.0
- Azure CLI authenticated (`az login`)

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Modify `terraform.tfvars` with your specific values

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. Clean up resources:
   ```bash
   terraform destroy
   ```

## Example Output

```
resource_group_id = "/subscriptions/xxxx-xxxx-xxxx-xxxx/resourceGroups/rg-dev-example-resource-group-eus"
resource_group_name = "rg-dev-example-resource-group-eus"
resource_group_location = "eastus"
resource_group_tags = {
  "Environment" = "dev"
  "Layer" = "infrastructure"
  "ManagedBy" = "Terraform"
  "Module" = "zrr-tf-module-lib/azure/infrastructure/resource-group"
  "Example" = "basic"
  "Project" = "zrr-example"
  "Owner" = "terraform"
}
```

## Notes

- This basic example uses the default naming convention (`rg-{environment}-{name}-{location_short}`)
- No resource locks or budget alerts are configured
- Suitable for development and testing environments