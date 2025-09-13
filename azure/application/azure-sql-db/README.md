# Azure Application - Azure SQL Database

This module creates an Azure SQL Database with comprehensive security, monitoring, and backup features following ZRR enterprise standards.

## Features

- **Security**: Threat detection, auditing, vulnerability assessment, and transparent data encryption
- **Performance**: Configurable SKUs, read scale-out, auto-pause for serverless workloads
- **Backup & Recovery**: Short-term and long-term retention policies, geo-redundant backups
- **Monitoring**: Built-in auditing and threat detection with configurable retention
- **Scalability**: Zone redundancy, read replicas, and flexible sizing options
- **Compliance**: Enterprise-grade security controls and governance features

## Usage

### Basic Example

```hcl
module "azure_sql_db" {
  source = "../../azure/application/azure-sql-db"

  name                = "myapp-database"
  sql_server_name     = "myapp-sql-server"
  resource_group_name = "myapp-rg"

  # Performance configuration
  sku_name     = "GP_S_Gen5_1"
  max_size_gb  = 10

  # Security settings
  enable_threat_detection = true
  enable_auditing        = true

  common_tags = {
    Environment = "production"
    Project     = "myapp"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with All Features

```hcl
module "azure_sql_db_advanced" {
  source = "../../azure/application/azure-sql-db"

  name                = "enterprise-database"
  sql_server_name     = "enterprise-sql-server"
  resource_group_name = "enterprise-rg"

  # Performance and scaling
  sku_name                    = "GP_Gen5_4"
  max_size_gb                = 500
  zone_redundant             = true
  read_scale                 = true
  read_replica_count         = 2

  # Backup and retention
  short_term_retention_days = 14
  backup_interval_in_hours  = 12

  long_term_retention_policy = {
    weekly_retention  = "P4W"
    monthly_retention = "P12M"
    yearly_retention  = "P5Y"
    week_of_year     = 1
  }

  # Security configuration
  enable_threat_detection                        = true
  threat_detection_email_admins                  = true
  threat_detection_email_addresses              = ["security@company.com"]
  threat_detection_retention_days               = 90
  transparent_data_encryption_enabled           = true

  # Auditing
  enable_auditing                               = true
  auditing_retention_days                       = 365
  auditing_log_monitoring_enabled              = true

  # Vulnerability assessment
  enable_vulnerability_assessment = true

  common_tags = {
    Environment = "production"
    Project     = "enterprise-app"
    Owner       = "data-team"
    Compliance  = "required"
  }

  azure_sql_db_tags = {
    Backup      = "critical"
    Monitoring  = "enhanced"
    Encryption  = "required"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_mssql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_server) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auditing_log_monitoring_enabled"></a> [auditing\_log\_monitoring\_enabled](#input\_auditing\_log\_monitoring\_enabled) | Enable log monitoring for audit logs | `bool` | `true` | no |
| <a name="input_auditing_retention_days"></a> [auditing\_retention\_days](#input\_auditing\_retention\_days) | Number of days to retain audit logs | `number` | `90` | no |
| <a name="input_auditing_storage_account_access_key"></a> [auditing\_storage\_account\_access\_key](#input\_auditing\_storage\_account\_access\_key) | Storage account access key for audit logs | `string` | `null` | no |
| <a name="input_auditing_storage_account_access_key_is_secondary"></a> [auditing\_storage\_account\_access\_key\_is\_secondary](#input\_auditing\_storage\_account\_access\_key\_is\_secondary) | Whether the storage account access key is secondary | `bool` | `false` | no |
| <a name="input_auditing_storage_endpoint"></a> [auditing\_storage\_endpoint](#input\_auditing\_storage\_endpoint) | Storage endpoint for audit logs | `string` | `null` | no |
| <a name="input_auto_pause_delay_in_minutes"></a> [auto\_pause\_delay\_in\_minutes](#input\_auto\_pause\_delay\_in\_minutes) | Time in minutes after which database is automatically paused (-1 to disable) | `number` | `-1` | no |
| <a name="input_azure_sql_db_tags"></a> [azure\_sql\_db\_tags](#input\_azure\_sql\_db\_tags) | Additional tags specific to the Azure SQL Database | `map(string)` | `{}` | no |
| <a name="input_backup_interval_in_hours"></a> [backup\_interval\_in\_hours](#input\_backup\_interval\_in\_hours) | Backup interval in hours (12 or 24) | `number` | `12` | no |
| <a name="input_collation"></a> [collation](#input\_collation) | Database collation | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "ManagedBy": "Terraform",<br>  "Project": "zrr"<br>}</pre> | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | Database creation mode | `string` | `"Default"` | no |
| <a name="input_creation_source_database_id"></a> [creation\_source\_database\_id](#input\_creation\_source\_database\_id) | ID of the source database for copy operations | `string` | `null` | no |
| <a name="input_enable_auditing"></a> [enable\_auditing](#input\_enable\_auditing) | Enable database auditing | `bool` | `true` | no |
| <a name="input_enable_threat_detection"></a> [enable\_threat\_detection](#input\_enable\_threat\_detection) | Enable threat detection for the database | `bool` | `true` | no |
| <a name="input_enable_vulnerability_assessment"></a> [enable\_vulnerability\_assessment](#input\_enable\_vulnerability\_assessment) | Enable vulnerability assessment | `bool` | `false` | no |
| <a name="input_geo_backup_enabled"></a> [geo\_backup\_enabled](#input\_geo\_backup\_enabled) | Enable geo-redundant backup | `bool` | `true` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type for the database (LicenseIncluded or BasePrice) | `string` | `"LicenseIncluded"` | no |
| <a name="input_long_term_retention_policy"></a> [long\_term\_retention\_policy](#input\_long\_term\_retention\_policy) | Long term retention policy configuration | <pre>object({<br>    weekly_retention  = optional(string, null)<br>    monthly_retention = optional(string, null)<br>    yearly_retention  = optional(string, null)<br>    week_of_year      = optional(number, null)<br>  })</pre> | `null` | no |
| <a name="input_max_size_gb"></a> [max\_size\_gb](#input\_max\_size\_gb) | Maximum size of the database in GB | `number` | `2` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum capacity for serverless databases | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure SQL Database | `string` | n/a | yes |
| <a name="input_read_replica_count"></a> [read\_replica\_count](#input\_read\_replica\_count) | Number of read replicas | `number` | `0` | no |
| <a name="input_read_scale"></a> [read\_scale](#input\_read\_scale) | Enable read scale-out for the database | `bool` | `false` | no |
| <a name="input_recover_database_id"></a> [recover\_database\_id](#input\_recover\_database\_id) | ID of the database to recover from | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group containing the SQL Server | `string` | n/a | yes |
| <a name="input_restore_dropped_database_id"></a> [restore\_dropped\_database\_id](#input\_restore\_dropped\_database\_id) | ID of the dropped database to restore | `string` | `null` | no |
| <a name="input_restore_point_in_time"></a> [restore\_point\_in\_time](#input\_restore\_point\_in\_time) | Point in time for restore operations (RFC3339 format) | `string` | `null` | no |
| <a name="input_short_term_retention_days"></a> [short\_term\_retention\_days](#input\_short\_term\_retention\_days) | Point in time retention in days | `number` | `7` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the database. Examples: GP\_S\_Gen5\_1, GP\_Gen5\_2, HS\_Gen5\_4, BC\_Gen5\_8 | `string` | `"GP_S_Gen5_1"` | no |
| <a name="input_sql_server_id"></a> [sql\_server\_id](#input\_sql\_server\_id) | ID of the Azure SQL Server. If not provided, sql\_server\_name must be specified | `string` | `null` | no |
| <a name="input_sql_server_name"></a> [sql\_server\_name](#input\_sql\_server\_name) | Name of the Azure SQL Server. Required if sql\_server\_id is not provided | `string` | `null` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Storage account type for backups (Local, Zone, Geo, GeoZone) | `string` | `"Geo"` | no |
| <a name="input_threat_detection_email_addresses"></a> [threat\_detection\_email\_addresses](#input\_threat\_detection\_email\_addresses) | List of email addresses to send threat detection alerts to | `list(string)` | `[]` | no |
| <a name="input_threat_detection_email_admins"></a> [threat\_detection\_email\_admins](#input\_threat\_detection\_email\_admins) | Send threat detection alerts to subscription admins | `bool` | `true` | no |
| <a name="input_threat_detection_retention_days"></a> [threat\_detection\_retention\_days](#input\_threat\_detection\_retention\_days) | Number of days to retain threat detection logs | `number` | `30` | no |
| <a name="input_threat_detection_storage_account_access_key"></a> [threat\_detection\_storage\_account\_access\_key](#input\_threat\_detection\_storage\_account\_access\_key) | Storage account access key for threat detection logs | `string` | `null` | no |
| <a name="input_threat_detection_storage_endpoint"></a> [threat\_detection\_storage\_endpoint](#input\_threat\_detection\_storage\_endpoint) | Storage endpoint for threat detection logs | `string` | `null` | no |
| <a name="input_transparent_data_encryption_enabled"></a> [transparent\_data\_encryption\_enabled](#input\_transparent\_data\_encryption\_enabled) | Enable transparent data encryption | `bool` | `true` | no |
| <a name="input_vulnerability_assessment_baseline_rules"></a> [vulnerability\_assessment\_baseline\_rules](#input\_vulnerability\_assessment\_baseline\_rules) | Vulnerability assessment baseline rules | <pre>list(object({<br>    rule_id          = string<br>    baseline_results = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether the database is zone redundant | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auditing_enabled"></a> [auditing\_enabled](#output\_auditing\_enabled) | Whether auditing is enabled |
| <a name="output_auto_pause_delay_in_minutes"></a> [auto\_pause\_delay\_in\_minutes](#output\_auto\_pause\_delay\_in\_minutes) | Auto pause delay in minutes |
| <a name="output_backup_interval_in_hours"></a> [backup\_interval\_in\_hours](#output\_backup\_interval\_in\_hours) | Backup interval in hours |
| <a name="output_collation"></a> [collation](#output\_collation) | Collation of the database |
| <a name="output_create_mode"></a> [create\_mode](#output\_create\_mode) | Database creation mode |
| <a name="output_geo_backup_enabled"></a> [geo\_backup\_enabled](#output\_geo\_backup\_enabled) | Whether geo-redundant backup is enabled |
| <a name="output_id"></a> [id](#output\_id) | ID of the Azure SQL Database |
| <a name="output_license_type"></a> [license\_type](#output\_license\_type) | License type of the database |
| <a name="output_max_size_gb"></a> [max\_size\_gb](#output\_max\_size\_gb) | Maximum size of the database in GB |
| <a name="output_min_capacity"></a> [min\_capacity](#output\_min\_capacity) | Minimum capacity for serverless databases |
| <a name="output_name"></a> [name](#output\_name) | Name of the Azure SQL Database |
| <a name="output_read_replica_count"></a> [read\_replica\_count](#output\_read\_replica\_count) | Number of read replicas |
| <a name="output_read_scale"></a> [read\_scale](#output\_read\_scale) | Whether read scale is enabled |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | ID of the Azure SQL Server hosting the database |
| <a name="output_short_term_retention_days"></a> [short\_term\_retention\_days](#output\_short\_term\_retention\_days) | Short term retention period in days |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | SKU name of the database |
| <a name="output_storage_account_type"></a> [storage\_account\_type](#output\_storage\_account\_type) | Storage account type for backups |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Azure SQL Database |
| <a name="output_threat_detection_enabled"></a> [threat\_detection\_enabled](#output\_threat\_detection\_enabled) | Whether threat detection is enabled |
| <a name="output_transparent_data_encryption_enabled"></a> [transparent\_data\_encryption\_enabled](#output\_transparent\_data\_encryption\_enabled) | Whether transparent data encryption is enabled |
| <a name="output_vulnerability_assessment_enabled"></a> [vulnerability\_assessment\_enabled](#output\_vulnerability\_assessment\_enabled) | Whether vulnerability assessment is enabled |
| <a name="output_zone_redundant"></a> [zone\_redundant](#output\_zone\_redundant) | Whether the database is zone redundant |
<!-- END_TF_DOCS -->