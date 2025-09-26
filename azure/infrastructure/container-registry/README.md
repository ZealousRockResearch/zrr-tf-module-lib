# Azure Container Registry Module

This module creates an Azure Container Registry (ACR) with support for image imports and scheduled tasks.

## Features

- ✅ Basic, Standard, and Premium SKU support
- ✅ Admin user configuration
- ✅ Network rules and IP restrictions (Premium)
- ✅ Geo-replication (Premium)
- ✅ Automated image import from Docker Hub
- ✅ Scheduled import tasks
- ✅ Encryption and trust policies (Premium)

## Usage

### Basic Container Registry

```hcl
module "container_registry" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/container-registry?ref=master"

  name                = "myacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "Basic"
  admin_enabled      = true

  common_tags = {
    Application = "MyApp"
    Environment = "dev"
  }
}
```

### With Image Import

```hcl
module "container_registry" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/container-registry?ref=master"

  name                = "myacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "Standard"
  admin_enabled      = true

  # Import images from Docker Hub
  images_to_import = {
    ghost = {
      source = "docker.io/library/ghost:5-alpine"
      target = "ghost:5-alpine"
    }
    nginx = {
      source = "docker.io/library/nginx:latest"
      target = "nginx:latest"
    }
  }

  common_tags = {
    Application = "MyApp"
    Environment = "prod"
  }
}
```

### Premium with Geo-replication

```hcl
module "container_registry" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/infrastructure/container-registry?ref=master"

  name                = "myacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = "Premium"
  admin_enabled      = true

  georeplications = [
    {
      location                = "westus2"
      zone_redundancy_enabled = true
    },
    {
      location                = "westeurope"
      zone_redundancy_enabled = false
    }
  ]

  network_rule_set = {
    default_action = "Deny"
    ip_rules = [
      {
        action   = "Allow"
        ip_range = "192.168.1.0/24"
      }
    ]
  }

  retention_policy = {
    enabled = true
    days    = 30
  }

  common_tags = {
    Application = "MyApp"
    Environment = "prod"
  }
}
```

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `name` | Container registry name (5-50 alphanumeric characters) | `string` | - | Yes |
| `resource_group_name` | Resource group name | `string` | - | Yes |
| `location` | Azure region | `string` | `"eastus"` | No |
| `sku` | SKU tier (Basic, Standard, Premium) | `string` | `"Basic"` | No |
| `admin_enabled` | Enable admin user | `bool` | `true` | No |
| `public_network_access_enabled` | Enable public network access | `bool` | `true` | No |
| `network_rule_set` | Network rules (Premium only) | `object` | `null` | No |
| `retention_policy` | Retention policy (Premium only) | `object` | `null` | No |
| `trust_policy` | Trust policy (Premium only) | `object` | `null` | No |
| `encryption` | Encryption settings (Premium only) | `object` | `null` | No |
| `identity_type` | Identity type | `string` | `null` | No |
| `identity_ids` | User assigned identity IDs | `list(string)` | `null` | No |
| `georeplications` | Geo-replication locations (Premium only) | `list(object)` | `[]` | No |
| `images_to_import` | Images to import from other registries | `map(object)` | `{}` | No |
| `scheduled_import_tasks` | Scheduled import tasks | `map(object)` | `{}` | No |
| `environment` | Environment name | `string` | `"dev"` | No |
| `common_tags` | Common tags for all resources | `map(string)` | `{}` | No |
| `acr_tags` | Additional ACR-specific tags | `map(string)` | `{}` | No |

## Outputs

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `id` | Container registry ID | No |
| `name` | Container registry name | No |
| `login_server` | Login server URL | No |
| `admin_username` | Admin username | Yes |
| `admin_password` | Admin password | Yes |
| `resource_group_name` | Resource group name | No |
| `location` | Location | No |
| `sku` | SKU tier | No |
| `identity` | Identity configuration | No |
| `imported_images` | Map of imported images | No |

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | ❌ | ❌ | ✅ |
| Network rules | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Customer-managed keys | ❌ | ❌ | ✅ |

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure CLI (for image import operations)