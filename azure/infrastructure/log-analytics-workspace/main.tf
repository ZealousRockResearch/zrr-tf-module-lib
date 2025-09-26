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

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  # Data export rules
  daily_quota_gb                     = var.daily_quota_gb
  internet_ingestion_enabled         = var.internet_ingestion_enabled
  internet_query_enabled             = var.internet_query_enabled
  local_authentication_disabled     = var.local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/log-analytics-workspace"
      Layer  = "infrastructure"
    },
    var.workspace_tags
  )
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "solutions" {
  for_each = var.solutions

  solution_name         = each.key
  location              = azurerm_log_analytics_workspace.main.location
  resource_group_name   = azurerm_log_analytics_workspace.main.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = each.value.publisher
    product   = each.value.product
  }

  tags = merge(
    var.common_tags,
    {
      Module   = "zrr-tf-module-lib/azure/infrastructure/log-analytics-workspace"
      Solution = each.key
    }
  )
}

# Data Collection Rules (optional)
resource "azurerm_monitor_data_collection_rule" "main" {
  for_each = var.data_collection_rules

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = each.value.description

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "destination-log"
    }
  }

  dynamic "data_flow" {
    for_each = each.value.data_flows
    content {
      streams      = data_flow.value.streams
      destinations = ["destination-log"]
    }
  }

  dynamic "data_sources" {
    for_each = length(each.value.performance_counters) > 0 ? [1] : []
    content {
      dynamic "performance_counter" {
        for_each = each.value.performance_counters
        content {
          streams                       = performance_counter.value.streams
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          counter_specifiers            = performance_counter.value.counter_specifiers
          name                          = performance_counter.value.name
        }
      }
    }
  }

  dynamic "data_sources" {
    for_each = length(each.value.windows_event_logs) > 0 ? [1] : []
    content {
      dynamic "windows_event_log" {
        for_each = each.value.windows_event_logs
        content {
          streams        = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
          name           = windows_event_log.value.name
        }
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/log-analytics-workspace"
      Type   = "data-collection-rule"
    }
  )
}

# Saved Searches (optional)
resource "azurerm_log_analytics_saved_search" "searches" {
  for_each = var.saved_searches

  name                       = each.key
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  category                   = each.value.category
  display_name               = each.value.display_name
  query                      = each.value.query

  function_alias      = each.value.function_alias
  function_parameters = each.value.function_parameters

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/infrastructure/log-analytics-workspace"
      Type   = "saved-search"
    }
  )
}