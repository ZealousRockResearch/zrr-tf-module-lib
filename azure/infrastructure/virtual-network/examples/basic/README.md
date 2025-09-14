# Basic VNet Example

This example demonstrates how to create a simple Azure Virtual Network using the ZRR Terraform module.

## Prerequisites

- Azure subscription
- Terraform >= 1.0
- Azure CLI authenticated (`az login`)
- Existing resource group

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Modify `terraform.tfvars` with your specific values:
   - Update `resource_group_name` to an existing resource group
   - Adjust `common_tags` as needed

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

## What This Example Creates

- **Virtual Network**: `vnet-dev-example-vnet-eus` (10.0.0.0/16)
- **Subnets**:
  - `subnet-web` (10.0.1.0/24) with Storage service endpoint
  - `subnet-app` (10.0.2.0/24) with Storage and KeyVault service endpoints
  - `subnet-data` (10.0.3.0/24) with private endpoint policies enabled
- **Network Security Groups**: One NSG per subnet with default security rules
- **Default NSG Rules**:
  - Allow VNet-to-VNet traffic
  - Allow Azure Load Balancer traffic
  - Deny all other inbound traffic

## Example Output

```
vnet_id = "/subscriptions/xxxx/resourceGroups/rg-dev-example-eus/providers/Microsoft.Network/virtualNetworks/vnet-dev-example-vnet-eus"
vnet_name = "vnet-dev-example-vnet-eus"
vnet_address_space = ["10.0.0.0/16"]
subnet_ids = {
  "subnet-app" = "/subscriptions/xxxx/.../subnets/subnet-app"
  "subnet-data" = "/subscriptions/xxxx/.../subnets/subnet-data"
  "subnet-web" = "/subscriptions/xxxx/.../subnets/subnet-web"
}
nsg_ids = {
  "subnet-app" = "/subscriptions/xxxx/.../networkSecurityGroups/nsg-subnet-app"
  "subnet-data" = "/subscriptions/xxxx/.../networkSecurityGroups/nsg-subnet-data"
  "subnet-web" = "/subscriptions/xxxx/.../networkSecurityGroups/nsg-subnet-web"
}
total_subnets = 3
```

## Notes

- This basic example uses the default naming convention (`vnet-{environment}-{name}-{location_short}`)
- All subnets get NSGs with security baseline rules
- Suitable for development and testing environments
- No DDoS protection, flow logs, or VNet peering configured