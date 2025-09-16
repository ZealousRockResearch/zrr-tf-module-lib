# Azure Security - MySQL Firewall Rule

This module manages Azure MySQL Firewall Rules with comprehensive security features, IP range management, and enterprise governance capabilities following ZRR standards.

## Features

- **Dual Server Support**: Compatible with both MySQL Single Server and MySQL Flexible Server deployments
- **Flexible Server Reference**: Supports server identification via ID, name-based lookup, or direct flexible server reference
- **Comprehensive IP Management**: Support for individual IPs, IP ranges, CIDR blocks, and predefined access patterns
- **Azure Services Integration**: Optional access for Azure services and resources with the special 0.0.0.0-0.0.0.0 rule
- **Office and Developer Access**: Predefined variables for common access scenarios (office IPs, developer workstations)
- **Application Network Access**: Support for application subnet CIDR blocks with validation
- **Security Validation**: Comprehensive IP address validation and range checking
- **Enterprise Governance**: Compliance tags, justification requirements, and monitoring capabilities
- **Environment-Aware**: Environment-specific validation and rule naming conventions
- **Monitoring Ready**: Built-in support for monitoring and alerting on firewall rule changes
- **Rule Limit Management**: Configurable limits to prevent Azure service limits from being exceeded
- **Comprehensive Outputs**: Detailed information about created rules, security configuration, and compliance status

## Usage

### Basic Example

```hcl
module "mysql_firewall_rules" {
  source = "../../azure/security/mysql-firewall-rule"

  mysql_server_name               = "my-mysql-server"
  mysql_server_resource_group_name = "my-resource-group"

  firewall_rules = [
    {
      name             = "AllowOfficeNetwork"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    }
  ]

  allow_azure_services = true

  common_tags = {
    Environment = "prod"
    Project     = "webapp"
    Owner       = "database-team"
  }
}
```

### Advanced Example with Multiple Access Patterns

```hcl
module "mysql_firewall_rules_advanced" {
  source = "../../azure/security/mysql-firewall-rule"

  mysql_flexible_server_name               = "my-flexible-mysql-server"
  mysql_flexible_server_resource_group_name = "my-resource-group"

  # Custom firewall rules
  firewall_rules = [
    {
      name             = "AllowDataCenter1"
      start_ip_address = "10.0.1.0"
      end_ip_address   = "10.0.1.255"
    },
    {
      name             = "AllowDataCenter2"
      start_ip_address = "10.0.2.0"
      end_ip_address   = "10.0.2.255"
    }
  ]

  # Predefined access patterns
  allow_office_ips = [
    "203.0.113.0/24",
    "198.51.100.50"
  ]

  allow_developer_ips = [
    "192.0.2.10",
    "192.0.2.20"
  ]

  allow_application_subnets = [
    "10.1.0.0/24",
    "10.2.0.0/24"
  ]

  allow_azure_services = true

  # Enterprise features
  environment              = "prod"
  enable_monitoring       = true
  alert_on_rule_changes   = true
  require_justification   = true
  max_firewall_rules     = 30

  compliance_tags = {
    DataClassification = "Internal"
    ComplianceScope   = "SOX"
    ReviewDate        = "2024-12-31"
  }

  common_tags = {
    Environment = "prod"
    Project     = "enterprise-app"
    Owner       = "security-team"
    CostCenter  = "IT"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mysql_firewall_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_firewall_rule) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |
| [null_resource.validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_mysql_flexible_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mysql_flexible_server) | data source |
| [azurerm_mysql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mysql_server) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_on_rule_changes"></a> [alert\_on\_rule\_changes](#input\_alert\_on\_rule\_changes) | Send alerts when firewall rules are modified | `bool` | `false` | no |
| <a name="input_allow_application_subnets"></a> [allow\_application\_subnets](#input\_allow\_application\_subnets) | List of application subnet CIDR blocks to allow access | `list(string)` | `[]` | no |
| <a name="input_allow_azure_services"></a> [allow\_azure\_services](#input\_allow\_azure\_services) | Whether to allow access from Azure services and resources | `bool` | `false` | no |
| <a name="input_allow_developer_ips"></a> [allow\_developer\_ips](#input\_allow\_developer\_ips) | List of developer IP addresses to allow access (for development environments) | `list(string)` | `[]` | no |
| <a name="input_allow_office_ips"></a> [allow\_office\_ips](#input\_allow\_office\_ips) | List of office IP addresses or ranges to allow access | `list(string)` | `[]` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "zrr"<br>}</pre> | no |
| <a name="input_compliance_tags"></a> [compliance\_tags](#input\_compliance\_tags) | Additional compliance tags to apply to firewall rules | `map(string)` | `{}` | no |
| <a name="input_enable_ip_range_validation"></a> [enable\_ip\_range\_validation](#input\_enable\_ip\_range\_validation) | Enable strict IP range validation (start\_ip <= end\_ip) | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable monitoring and alerting for firewall rule changes | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (used for rule naming and validation) | `string` | `"dev"` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | List of firewall rules to create for the MySQL server | <pre>list(object({<br>    name             = string<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | `[]` | no |
| <a name="input_max_firewall_rules"></a> [max\_firewall\_rules](#input\_max\_firewall\_rules) | Maximum number of firewall rules allowed (Azure limit is 128) | `number` | `50` | no |
| <a name="input_mysql_firewall_rule_tags"></a> [mysql\_firewall\_rule\_tags](#input\_mysql\_firewall\_rule\_tags) | Additional tags specific to the MySQL firewall rules | `map(string)` | `{}` | no |
| <a name="input_mysql_flexible_server_name"></a> [mysql\_flexible\_server\_name](#input\_mysql\_flexible\_server\_name) | Name of the MySQL Flexible Server | `string` | `null` | no |
| <a name="input_mysql_flexible_server_resource_group_name"></a> [mysql\_flexible\_server\_resource\_group\_name](#input\_mysql\_flexible\_server\_resource\_group\_name) | Resource group name of the MySQL Flexible Server (required when using mysql\_flexible\_server\_name) | `string` | `null` | no |
| <a name="input_mysql_server_id"></a> [mysql\_server\_id](#input\_mysql\_server\_id) | Resource ID of the MySQL server (supports both Single Server and Flexible Server) | `string` | `null` | no |
| <a name="input_mysql_server_name"></a> [mysql\_server\_name](#input\_mysql\_server\_name) | Name of the MySQL Single Server | `string` | `null` | no |
| <a name="input_mysql_server_resource_group_name"></a> [mysql\_server\_resource\_group\_name](#input\_mysql\_server\_resource\_group\_name) | Resource group name of the MySQL Single Server (required when using mysql\_server\_name) | `string` | `null` | no |
| <a name="input_require_justification"></a> [require\_justification](#input\_require\_justification) | Require justification tags for firewall rules in production environments | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applied_tags"></a> [applied\_tags](#output\_applied\_tags) | Tags applied to the firewall rules |
| <a name="output_application_subnets_count"></a> [application\_subnets\_count](#output\_application\_subnets\_count) | Number of application subnets configured |
| <a name="output_azure_services_allowed"></a> [azure\_services\_allowed](#output\_azure\_services\_allowed) | Whether Azure services access is enabled |
| <a name="output_compliance_status"></a> [compliance\_status](#output\_compliance\_status) | Compliance and governance status |
| <a name="output_developer_ips_count"></a> [developer\_ips\_count](#output\_developer\_ips\_count) | Number of developer IP addresses configured |
| <a name="output_firewall_rule_ids"></a> [firewall\_rule\_ids](#output\_firewall\_rule\_ids) | Map of firewall rule names to their IDs |
| <a name="output_firewall_rule_names"></a> [firewall\_rule\_names](#output\_firewall\_rule\_names) | List of created firewall rule names |
| <a name="output_firewall_rules_count"></a> [firewall\_rules\_count](#output\_firewall\_rules\_count) | Total number of firewall rules created |
| <a name="output_firewall_rules_details"></a> [firewall\_rules\_details](#output\_firewall\_rules\_details) | Detailed information about all firewall rules |
| <a name="output_mysql_server_reference"></a> [mysql\_server\_reference](#output\_mysql\_server\_reference) | Reference information for the MySQL server |
| <a name="output_network_access_summary"></a> [network\_access\_summary](#output\_network\_access\_summary) | Summary of network access configuration |
| <a name="output_office_ips_count"></a> [office\_ips\_count](#output\_office\_ips\_count) | Number of office IP ranges configured |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Summary of security configuration |
| <a name="output_server_name"></a> [server\_name](#output\_server\_name) | Name of the MySQL server |
| <a name="output_server_type"></a> [server\_type](#output\_server\_type) | Type of MySQL server (single or flexible) |