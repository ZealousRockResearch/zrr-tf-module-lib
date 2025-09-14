# Azure Security - Network Security Group

This Terraform module creates and manages Azure Network Security Groups (NSGs) with configurable security rules, associations, and advanced features like flow logging.

## Features

- **Comprehensive NSG Management**: Create and configure Network Security Groups with custom security rules
- **Flexible Rule Configuration**: Support for both simple and complex security rule definitions
- **Multiple Association Types**: Associate NSGs with subnets or network interfaces
- **Resource Group Management**: Optionally create or use existing resource groups
- **Flow Logging Support**: Configure flow logs for network traffic analysis
- **Tag Management**: Comprehensive tagging with common and resource-specific tags
- **Validation**: Extensive input validation for all parameters
- **Enterprise Standards**: Follows ZRR enterprise standards and best practices

## Usage

### Basic Example

```hcl
module "network_security_group" {
  source = "../../azure/security/network-security-group"

  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-rg"

  security_rules = [
    {
      name                       = "allow-ssh"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH access"
    }
  ]

  common_tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Advanced Example with Flow Logs

```hcl
module "advanced_nsg" {
  source = "../../azure/security/network-security-group"

  name                = "advanced-nsg"
  location            = "East US"
  resource_group_name = "example-rg"

  security_rules = [
    {
      name                         = "allow-http-https"
      priority                     = 1000
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = ["80", "443"]
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      description                  = "Allow HTTP and HTTPS traffic"
    },
    {
      name                         = "deny-all-inbound"
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "*"
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      description                  = "Deny all other inbound traffic"
    }
  ]

  enable_flow_logs              = true
  flow_log_storage_account_id   = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/xxx"
  flow_log_retention_days       = 90

  subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/xxx/subnets/xxx"

  common_tags = {
    Environment = "production"
    Project     = "webapp"
    Owner       = "security-team"
  }

  network_security_group_tags = {
    Purpose = "web-tier"
    Backup  = "daily"
  }
}
```

## Security Rules

Security rules support the following configuration options:

- **Priority**: Must be between 100-4096 (lower numbers have higher priority)
- **Direction**: Inbound or Outbound
- **Access**: Allow or Deny
- **Protocol**: Tcp, Udp, Icmp, Esp, Ah, or * (any)
- **Port Ranges**: Single port, port range, or list of ports
- **Address Prefixes**: IP addresses, CIDR blocks, or service tags

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_network_security_group.main | resource |
| azurerm_network_security_rule.main | resource |
| azurerm_subnet_network_security_group_association.main | resource |
| azurerm_network_interface_security_group_association.main | resource |
| azurerm_resource_group.main | resource |
| azurerm_resource_group.main | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the network security group | `string` | n/a | yes |
| location | Azure region where the network security group will be created | `string` | `"East US"` | no |
| resource_group_name | Name of the resource group. Required if create_resource_group is false | `string` | `null` | no |
| create_resource_group | Whether to create a new resource group | `bool` | `false` | no |
| common_tags | Common tags to be applied to all resources | `map(string)` | `{"Environment": "dev", "ManagedBy": "Terraform", "Project": "zrr"}` | no |
| network_security_group_tags | Additional tags specific to the network security group | `map(string)` | `{}` | no |
| security_rules | List of security rules to create | `list(object)` | `[]` | no |
| subnet_id | ID of the subnet to associate with the network security group | `string` | `null` | no |
| network_interface_ids | List of network interface IDs to associate with the network security group | `list(string)` | `[]` | no |
| enable_flow_logs | Enable flow logs for the network security group | `bool` | `false` | no |
| flow_log_storage_account_id | Storage account ID for flow logs (required if enable_flow_logs is true) | `string` | `null` | no |
| flow_log_retention_days | Number of days to retain flow logs | `number` | `30` | no |
| flow_log_format_type | Format type for flow logs | `string` | `"JSON"` | no |
| flow_log_format_version | Format version for flow logs | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the network security group |
| name | Name of the network security group |
| location | Location of the network security group |
| resource_group_name | Resource group name of the network security group |
| security_rules | List of security rules created |
| security_rule_ids | Map of security rule names to their IDs |
| subnet_association_id | ID of the subnet association (if created) |
| network_interface_association_ids | Map of network interface IDs to their association IDs |
| resource_group_id | ID of the resource group (if created by this module) |
| tags | Tags applied to the network security group |
| effective_security_rules_count | Number of security rules created |
| has_inbound_rules | Whether the NSG has any inbound rules |
| has_outbound_rules | Whether the NSG has any outbound rules |
| inbound_rules_count | Number of inbound security rules |
| outbound_rules_count | Number of outbound security rules |