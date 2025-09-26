# Azure Log Analytics Workspace Module

This module creates an Azure Log Analytics Workspace with optional solutions, data collection rules, and saved searches.

## Features

- ✅ Log Analytics Workspace with configurable SKU and retention
- ✅ Data ingestion and query configuration
- ✅ Identity management (System/User assigned)
- ✅ Log Analytics Solutions (ContainerInsights, etc.)
- ✅ Data Collection Rules for custom monitoring
- ✅ Saved Searches for common queries
- ✅ Daily quota and capacity reservation support

## Usage

### Basic Log Analytics Workspace

```hcl
module "log_analytics" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/log-analytics-workspace?ref=master"

  name                = "law-myapp-dev"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "PerGB2018"
  retention_in_days  = 30

  common_tags = {
    Application = "MyApp"
    Environment = "dev"
  }
}
```

### With Container Insights Solution

```hcl
module "log_analytics" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/log-analytics-workspace?ref=master"

  name                = "law-containers-prod"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "PerGB2018"
  retention_in_days  = 90
  daily_quota_gb     = 5

  solutions = {
    ContainerInsights = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
  }

  common_tags = {
    Application = "ContainerPlatform"
    Environment = "prod"
  }
}
```

### With Custom Data Collection Rules

```hcl
module "log_analytics" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/log-analytics-workspace?ref=master"

  name                = "law-monitoring-prod"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "PerGB2018"
  retention_in_days  = 365

  data_collection_rules = {
    performance_monitoring = {
      description = "Collect performance counters"
      data_flows = [
        {
          streams = ["Microsoft-Perf"]
        }
      ]
      performance_counters = [
        {
          streams                       = ["Microsoft-Perf"]
          sampling_frequency_in_seconds = 60
          counter_specifiers           = ["\\Processor(_Total)\\% Processor Time", "\\Memory\\Available MBytes"]
          name                         = "perfCounterDataSource60"
        }
      ]
      windows_event_logs = []
    }
  }

  saved_searches = {
    error_logs = {
      category     = "Application"
      display_name = "Application Errors"
      query        = "search * | where Level == \"Error\" | order by TimeGenerated desc"
    }
  }

  common_tags = {
    Application = "Monitoring"
    Environment = "prod"
  }
}
```

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `name` | Log Analytics workspace name | `string` | - | Yes |
| `resource_group_name` | Resource group name | `string` | - | Yes |
| `location` | Azure region | `string` | `"eastus"` | No |
| `sku` | Workspace SKU | `string` | `"PerGB2018"` | No |
| `retention_in_days` | Data retention period (30-730) | `number` | `30` | No |
| `daily_quota_gb` | Daily ingestion quota in GB (-1 for unlimited) | `number` | `-1` | No |
| `internet_ingestion_enabled` | Enable internet ingestion | `bool` | `true` | No |
| `internet_query_enabled` | Enable internet query | `bool` | `true` | No |
| `local_authentication_disabled` | Disable local authentication | `bool` | `false` | No |
| `reservation_capacity_in_gb_per_day` | Capacity reservation level | `number` | `null` | No |
| `identity_type` | Identity type (SystemAssigned/UserAssigned) | `string` | `null` | No |
| `identity_ids` | User assigned identity IDs | `list(string)` | `null` | No |
| `solutions` | Map of Log Analytics solutions | `map(object)` | `{}` | No |
| `data_collection_rules` | Map of data collection rules | `map(object)` | `{}` | No |
| `saved_searches` | Map of saved searches | `map(object)` | `{}` | No |
| `environment` | Environment name | `string` | `"dev"` | No |
| `common_tags` | Common tags for all resources | `map(string)` | `{}` | No |
| `workspace_tags` | Additional workspace-specific tags | `map(string)` | `{}` | No |

## Outputs

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `id` | Workspace resource ID | No |
| `name` | Workspace name | No |
| `workspace_id` | Workspace ID (GUID) | No |
| `primary_shared_key` | Primary shared key | Yes |
| `secondary_shared_key` | Secondary shared key | Yes |
| `location` | Workspace location | No |
| `resource_group_name` | Resource group name | No |
| `sku` | Workspace SKU | No |
| `retention_in_days` | Data retention period | No |
| `connection_info` | Complete connection information | Yes |
| `solutions` | Map of installed solutions | No |
| `data_collection_rules` | Map of data collection rules | No |
| `saved_searches` | Map of saved searches | No |

## SKU Options

| SKU | Description | Use Case |
|-----|-------------|----------|
| `Free` | 500 MB/day, 7 days retention | Testing only |
| `PerGB2018` | Pay per GB ingested | Most common |
| `PerNode` | Per monitored node | Legacy |
| `Premium` | Higher limits | Large scale |
| `CapacityReservation` | Reserved capacity | Predictable costs |

## Common Solutions

```hcl
solutions = {
  # Container monitoring
  ContainerInsights = {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  # Security monitoring
  Security = {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  # Update management
  Updates = {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  # Change tracking
  ChangeTracking = {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }
}
```

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.0
- Appropriate Azure permissions for Log Analytics operations

## Cost Considerations

- **PerGB2018**: ~$2.30 per GB ingested
- **Retention**: Additional cost for data retention beyond 31 days
- **Daily Quota**: Set limits to control costs
- **Capacity Reservation**: Can provide cost savings for high volume

For Container Apps, typically expect 1-5 GB/month for a small application (~$2-12/month).