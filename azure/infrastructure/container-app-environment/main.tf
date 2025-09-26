terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Data sources
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Only set these advanced networking features if subnet is provided
  infrastructure_subnet_id         = var.infrastructure_subnet_id
  internal_load_balancer_enabled   = var.infrastructure_subnet_id != null && var.internal_load_balancer_enabled ? true : null
  zone_redundancy_enabled          = var.infrastructure_subnet_id != null && var.zone_redundancy_enabled ? true : null

  # Workload profiles (optional - for dedicated environments)
  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      maximum_count         = workload_profile.value.maximum_count
      minimum_count         = workload_profile.value.minimum_count
    }
  }

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/container-app-environment"
      Layer  = "infrastructure"
    },
    var.environment_tags
  )
}

# Container App Environment Storage (optional)
resource "azurerm_container_app_environment_storage" "storage" {
  for_each = nonsensitive(var.storage_accounts)

  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = each.value.account_name
  share_name                   = each.value.share_name
  access_key                   = each.value.access_key
  access_mode                  = each.value.access_mode
}

# Container App Environment Certificate (optional)
resource "azurerm_container_app_environment_certificate" "certificates" {
  for_each = nonsensitive(var.certificates)

  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.main.id
  certificate_blob_base64      = each.value.certificate_blob_base64
  certificate_password         = each.value.certificate_password

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/container-app-environment"
      Type   = "certificate"
    }
  )
}

# Container App Environment Dapr Component (optional)
resource "azurerm_container_app_environment_dapr_component" "dapr_components" {
  for_each = nonsensitive(var.dapr_components)

  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.main.id
  component_type               = each.value.component_type
  version                      = each.value.version
  ignore_errors                = each.value.ignore_errors
  init_timeout                 = each.value.init_timeout
  scopes                       = each.value.scopes

  dynamic "metadata" {
    for_each = each.value.metadata
    content {
      name  = metadata.value.name
      value = metadata.value.value
    }
  }

  dynamic "secret" {
    for_each = each.value.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }
}