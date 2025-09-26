terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Data source for current subscription
data "azurerm_subscription" "current" {}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Public network access
  public_network_access_enabled = var.public_network_access_enabled

  # Network rule set for Premium SKU
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = lookup(network_rule_set.value, "ip_rules", [])
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  # Retention policy for Premium SKU
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy != null ? [var.retention_policy] : []
    content {
      enabled = retention_policy.value.enabled
      days    = retention_policy.value.days
    }
  }

  # Trust policy for Premium SKU
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy != null ? [var.trust_policy] : []
    content {
      enabled = trust_policy.value.enabled
    }
  }

  # Encryption for Premium SKU
  dynamic "encryption" {
    for_each = var.sku == "Premium" && var.encryption != null ? [var.encryption] : []
    content {
      enabled            = encryption.value.enabled
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Georeplications for Premium SKU
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                = georeplications.value.location
      tags                    = georeplications.value.tags
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/container-registry"
      Layer  = "infrastructure"
    },
    var.acr_tags
  )
}

# Import Docker Hub images to ACR (optional)
resource "null_resource" "import_images" {
  for_each = var.images_to_import

  provisioner "local-exec" {
    command = <<-EOT
      az acr import \
        --name ${azurerm_container_registry.main.name} \
        --source ${each.value.source} \
        --image ${each.value.target != null ? each.value.target : each.value.source} \
        --force
    EOT
  }

  triggers = {
    registry_id = azurerm_container_registry.main.id
    image_source = each.value.source
  }

  depends_on = [azurerm_container_registry.main]
}

# ACR Tasks for scheduled image imports (optional)
resource "azurerm_container_registry_task" "import_task" {
  for_each = var.scheduled_import_tasks

  name                  = each.key
  container_registry_id = azurerm_container_registry.main.id

  platform {
    os           = "Linux"
    architecture = "amd64"
  }

  encoded_step {
    task_content = base64encode(yamlencode({
      version = "v1.1.0"
      steps = [
        {
          cmd = "mcr.microsoft.com/acr/acr-cli:0.6 import --source ${each.value.source} --target ${each.value.target}"
        }
      ]
    }))
  }

  dynamic "timer_trigger" {
    for_each = each.value.schedule != null ? [1] : []
    content {
      name     = "${each.key}-schedule"
      schedule = each.value.schedule
      enabled  = true
    }
  }

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/container-registry"
      Task   = "import"
    }
  )
}