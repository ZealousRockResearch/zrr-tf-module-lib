# Azure App Service Plan - Basic Example

This example demonstrates the basic usage of the Azure App Service Plan module with minimal configuration.

## Features Demonstrated

- Basic App Service Plan creation with Linux OS
- Basic tier SKU (B1) configuration
- Standard tagging strategy
- Simple scaling configuration

## Prerequisites

- Resource group for the App Service Plan
- Appropriate Azure permissions to create App Service Plans

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Update the variables with your specific values
3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Required Variables

- `resource_group_name`: Name of your existing resource group
- `location`: Azure region for deployment

### Optional Variables

All other variables have sensible defaults for a basic configuration:

- OS Type: `Linux`
- SKU: `B1` (Basic tier, 1 core, 1.75 GB RAM)
- Worker Count: `1` instance
- Per-site Scaling: Disabled

## SKU Options

### Basic Tier
- `B1`: 1 core, 1.75 GB RAM
- `B2`: 2 cores, 3.5 GB RAM
- `B3`: 4 cores, 7 GB RAM

### Standard Tier
- `S1`: 1 core, 1.75 GB RAM (supports auto-scaling, custom domains)
- `S2`: 2 cores, 3.5 GB RAM
- `S3`: 4 cores, 7 GB RAM

### Premium Tier
- `P1v2`: 1 core, 3.5 GB RAM (supports VNet integration, SSL)
- `P2v2`: 2 cores, 7 GB RAM
- `P3v2`: 4 cores, 14 GB RAM
- `P1v3`: 1 core, 4 GB RAM (improved performance)
- `P2v3`: 2 cores, 8 GB RAM
- `P3v3`: 4 cores, 16 GB RAM

## Example Output

After successful deployment, you'll see outputs similar to:

```
app_service_plan_id = "/subscriptions/.../resourceGroups/my-rg/providers/Microsoft.Web/serverfarms/example-service-plan"
app_service_plan_name = "example-service-plan"
os_type = "Linux"
sku_name = "B1"
worker_count = 1
```

## Clean Up

```bash
terraform destroy
```

## Next Steps

- Review the [advanced example](../advanced/README.md) for auto-scaling and monitoring
- Connect Azure App Services to this App Service Plan
- Consider upgrading to Standard or Premium tiers for production workloads
- Implement monitoring and alerting for production environments