module "app_service_plan_advanced" {
  source = "../../"

  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Performance and scaling configuration
  os_type                      = var.os_type
  sku_name                     = var.sku_name
  worker_count                 = var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  zone_balancing_enabled       = var.zone_balancing_enabled
  per_site_scaling_enabled     = var.per_site_scaling_enabled

  # Auto-scaling configuration
  enable_autoscaling      = var.enable_autoscaling
  autoscale_settings      = var.autoscale_settings
  autoscale_notifications = var.autoscale_notifications

  # Monitoring and diagnostics
  enable_diagnostic_settings = var.enable_diagnostic_settings
  log_analytics_workspace_id = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : var.existing_log_analytics_workspace_id
  diagnostic_log_categories  = var.diagnostic_log_categories
  diagnostic_metrics         = var.diagnostic_metrics

  # Alerting
  enable_alerts                     = var.enable_alerts
  alert_action_group_name           = var.create_action_group ? azurerm_monitor_action_group.main[0].name : var.existing_action_group_name
  alert_action_group_resource_group = var.resource_group_name
  cpu_alert_settings                = var.cpu_alert_settings
  memory_alert_settings             = var.memory_alert_settings

  common_tags           = var.common_tags
  application_plan_tags = var.application_plan_tags
}

# Additional resources for advanced example

# Log Analytics Workspace (if creating new one)
resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_log_analytics ? 1 : 0

  name                = "${var.service_plan_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = merge(var.common_tags, {
    Purpose = "app-service-monitoring"
  })
}

# Action Group for alerts (if creating new one)
resource "azurerm_monitor_action_group" "main" {
  count = var.create_action_group ? 1 : 0

  name                = "${var.service_plan_name}-alerts"
  resource_group_name = var.resource_group_name
  short_name          = substr("${var.service_plan_name}-alt", 0, 12)

  # Email notifications
  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  # SMS notifications
  dynamic "sms_receiver" {
    for_each = var.alert_sms_receivers
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  # Webhook notifications
  dynamic "webhook_receiver" {
    for_each = var.alert_webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  # Azure Function notifications
  dynamic "azure_function_receiver" {
    for_each = var.alert_function_receivers
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
    }
  }

  tags = merge(var.common_tags, {
    Purpose = "app-service-alerting"
  })
}

# Application Insights (optional)
resource "azurerm_application_insights" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "${var.service_plan_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.create_log_analytics ? azurerm_log_analytics_workspace.main[0].id : var.existing_log_analytics_workspace_id
  application_type    = "web"
  retention_in_days   = var.application_insights_retention_days

  tags = merge(var.common_tags, {
    Purpose = "app-service-insights"
  })
}

# Storage Account for diagnostic logs (optional)
resource "azurerm_storage_account" "diagnostics" {
  count = var.create_diagnostics_storage ? 1 : 0

  name                     = "${replace(lower(var.service_plan_name), "-", "")}diag${random_string.storage_suffix[0].result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = false
    delete_retention_policy {
      days = var.diagnostics_storage_retention_days
    }
  }

  tags = merge(var.common_tags, {
    Purpose = "app-service-diagnostics"
  })
}

resource "random_string" "storage_suffix" {
  count = var.create_diagnostics_storage ? 1 : 0

  length  = 4
  special = false
  upper   = false
}

# Network Security Group for App Service subnet (if using VNet integration)
resource "azurerm_network_security_group" "app_service" {
  count = var.create_app_service_nsg ? 1 : 0

  name                = "${var.service_plan_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Outbound rules for App Service
  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowDNSOutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Inbound rules for App Service
  security_rule {
    name                       = "AllowAppServiceInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.common_tags, {
    Purpose = "app-service-network-security"
  })
}