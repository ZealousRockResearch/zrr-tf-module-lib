# Advanced VNet Example - Hub-and-Spoke Architecture

This example demonstrates an enterprise-grade hub-and-spoke network architecture using the ZRR VNet module, including:

- Hub VNet with shared services
- Multiple spoke VNets for different workloads
- VNet peering for connectivity
- DDoS protection and advanced monitoring
- Auto-calculated subnet addressing
- Service delegations and endpoints

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────┐                                  │
│  │       Hub VNet           │                                  │
│  │    (10.0.0.0/16)         │                                  │
│  │                          │                                  │
│  │  • GatewaySubnet         │◄──────┐                          │
│  │  • AzureFirewallSubnet   │       │                          │
│  │  • SharedServices        │       │                          │
│  │  • Management           │       │                          │
│  │                          │       │                          │
│  │  DDoS Protection: ✓      │       │                          │
│  │  Flow Logs: ✓           │       │                          │
│  └──────────────────────────┘       │                          │
│              │                      │                          │
│              │ Peering              │ Peering                  │
│              ▼                      │                          │
│  ┌──────────────────────────┐       │                          │
│  │    Spoke 1 VNet          │       │                          │
│  │   (10.1.0.0/16)          │       │                          │
│  │   Production Workloads   │       │                          │
│  │                          │       │                          │
│  │  • Web Tier             │       │                          │
│  │  • App Tier             │       │                          │
│  │  • Data Tier            │       │                          │
│  │  • Integration          │       │                          │
│  │                          │       │                          │
│  │  Flow Logs: ✓           │       │                          │
│  └──────────────────────────┘       │                          │
│                                     │                          │
│                                     ▼                          │
│                          ┌──────────────────────────┐          │
│                          │    Spoke 2 VNet          │          │
│                          │   (10.2.0.0/16)          │          │
│                          │   Development/Test       │          │
│                          │                          │          │
│                          │  • Dev Web              │          │
│                          │  • Dev App              │          │
│                          │  • Test Environment     │          │
│                          │                          │          │
│                          │  Flow Logs: ✗           │          │
│                          └──────────────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Azure CLI authenticated (`az login`)
- Existing resource groups for hub and spoke VNets
- DDoS protection plan (optional but recommended for production)
- Log Analytics workspace for traffic analytics
- Storage account for flow logs

## Usage

1. Copy and customize the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your organization's values:
   - Update resource group names
   - Configure DDoS protection plan ID
   - Set Log Analytics workspace details
   - Configure storage account for flow logs
   - Adjust DNS servers for your environment
   - Update tags to match your governance requirements

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration (requires approval):
   ```bash
   terraform apply
   ```

6. Verify the deployment:
   ```bash
   terraform output network_architecture_summary
   ```

## What This Example Creates

### Hub VNet (10.0.0.0/16)
- **GatewaySubnet** (10.0.1.0/27) - For VPN/ExpressRoute gateways
- **AzureFirewallSubnet** (10.0.2.0/26) - For Azure Firewall
- **subnet-shared-services** (10.0.3.0/24) - Shared enterprise services
- **subnet-management** (10.0.4.0/24) - Management and monitoring tools

### Spoke 1 VNet - Production (10.1.0.0/16)
- **subnet-web** (10.1.0.0/24) - Web tier with App Service delegation
- **subnet-app** (10.1.1.0/24) - Application tier
- **subnet-data** (10.1.2.0/22) - Data tier with private endpoints
- **subnet-integration** (10.1.6.0/24) - Integration services with Logic Apps delegation

### Spoke 2 VNet - Development (10.2.0.0/16)
- **subnet-dev-web** (10.2.0.0/24) - Development web tier
- **subnet-dev-app** (10.2.1.0/24) - Development application tier
- **subnet-test** (10.2.2.0/24) - Testing environment

## Advanced Features Demonstrated

### 1. Auto-calculated Subnets
```hcl
auto_calculate_subnets = true
subnets = [
  {
    name    = "subnet-web"
    newbits = 8  # Auto-calculates address from VNet space
  }
]
```

### 2. Service Delegations
```hcl
delegations = [
  {
    name = "webapp-delegation"
    service_delegation = {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
]
```

### 3. VNet Peering
- Bidirectional peering between hub and spokes
- Gateway transit enabled on hub
- Remote gateway usage on spokes

### 4. Enterprise Monitoring
- Network Watcher flow logs
- Traffic analytics with Log Analytics
- Different retention policies per environment

### 5. DDoS Protection
- Enterprise DDoS protection plan
- Applied to hub VNet for comprehensive coverage

## Security Features

- Default NSG rules for security baseline
- Private endpoint policies enabled where appropriate
- Service endpoints for secure Azure service access
- Route tables for traffic control
- Flow logs for security monitoring

## Cost Optimization

- Development VNet has reduced monitoring (no flow logs)
- Appropriate subnet sizing based on workload requirements
- Shared DDoS protection across all VNets

## Monitoring and Operations

- Enhanced flow logs with 90-day retention for production
- Traffic analytics for network insights
- Comprehensive tagging for cost allocation
- Standardized naming for operational clarity

## Clean Up

⚠️ **Warning**: This creates enterprise networking infrastructure.

To destroy the resources:
```bash
terraform destroy
```

Note: Peering relationships are automatically cleaned up by Terraform.

## Next Steps

After deploying this network architecture:

1. **Configure Azure Firewall** in the AzureFirewallSubnet
2. **Deploy VPN/ExpressRoute Gateway** in the GatewaySubnet
3. **Set up routing** to direct traffic through the firewall
4. **Configure DNS** forwarding for hybrid connectivity
5. **Deploy workloads** in the appropriate spoke subnets
6. **Set up monitoring** dashboards and alerts
7. **Configure backup** for network configurations

## Troubleshooting

- Ensure all required resource groups exist before deployment
- Verify DDoS protection plan is in the same region
- Check that storage account and Log Analytics workspace are accessible
- Validate that Network Watcher is enabled in the target region