# Advanced Network Security Group Example

This example demonstrates advanced usage of the Azure Network Security Group module with comprehensive security rules, flow logging, and network segmentation.

## Features Demonstrated

- **Comprehensive Security Rules**: Multiple inbound and outbound rules with different priorities
- **Network Segmentation**: Rules that allow traffic only from specific subnets
- **Flow Logging**: Enabled with custom retention and storage configuration
- **Multiple Associations**: Both subnet and network interface associations
- **Advanced Tagging**: Comprehensive tag strategy for enterprise environments
- **Service Tags**: Using Azure service tags for simplified rule management

## Architecture

This example implements a typical 3-tier application security model:

1. **Web Tier**: Allows HTTP/HTTPS traffic from internet
2. **Management Access**: SSH access restricted to management subnets only
3. **Database Tier**: Database access restricted to application subnets only
4. **Outbound Control**: Blocks internet outbound while allowing VNet communication

## Security Rules Overview

| Priority | Name | Direction | Access | Protocol | Ports | Source | Destination | Description |
|----------|------|-----------|--------|----------|-------|--------|-------------|--------------|
| 1000 | allow-web-traffic | Inbound | Allow | TCP | 80,443 | * | * | HTTP/HTTPS from internet |
| 1001 | allow-ssh-from-mgmt | Inbound | Allow | TCP | 22 | Mgmt Subnets | * | SSH from management only |
| 1002 | allow-database-from-app | Inbound | Allow | TCP | 3306,5432,1433 | App Subnets | * | DB access from app tier |
| 2000 | allow-vnet-outbound | Outbound | Allow | * | * | * | VirtualNetwork | Allow internal VNet traffic |
| 3000 | deny-internet-outbound | Outbound | Deny | * | * | * | Internet | Block internet outbound |
| 4000 | deny-all-inbound | Inbound | Deny | * | * | * | * | Deny all other inbound |

## Prerequisites

- Existing Resource Group
- Storage Account for flow logs (if flow logging enabled)
- Virtual Network and Subnets (if using associations)
- Network Interfaces (if using NIC associations)

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update the variables according to your Azure environment:
   - Replace subscription IDs with your actual subscription ID
   - Update resource group names to match your environment
   - Adjust subnet CIDR blocks to match your network design
   - Configure storage account for flow logs
3. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Flow Logs Configuration

This example enables Network Security Group flow logs with the following features:

- **Storage**: Logs stored in specified Azure Storage Account
- **Retention**: 90-day retention period
- **Format**: JSON format version 2
- **Analytics**: Can be integrated with Azure Sentinel or Log Analytics

## Network Segmentation

The example implements network segmentation using multiple address prefixes:

- **Management Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Application Subnets**: `10.0.10.0/24`, `10.0.11.0/24`

Adjust these ranges to match your network architecture.

## Security Best Practices Implemented

1. **Principle of Least Privilege**: Each rule grants minimum necessary access
2. **Defense in Depth**: Multiple layers of security controls
3. **Network Segmentation**: Traffic restricted between network tiers
4. **Logging and Monitoring**: Flow logs enabled for security monitoring
5. **Explicit Deny**: Default deny rule at the end of the rule list

## Monitoring and Alerting

With flow logs enabled, you can:

- Monitor network traffic patterns
- Detect anomalous connections
- Investigate security incidents
- Perform compliance auditing
- Set up automated alerts for suspicious activity

## Clean up

To destroy the resources:

```bash
terraform destroy
```

**Note**: Ensure flow log storage account data is backed up if needed before destroying resources.