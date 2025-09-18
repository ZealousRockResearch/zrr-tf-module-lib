# azure-application-container-instance module
# Description: Manages Azure Container Instances with comprehensive enterprise features including multi-container support, networking, storage, monitoring, and security

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "container_instance" {
  count = var.resource_group_id != null ? 0 : 1
  name  = var.resource_group_name
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.container_instance_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/application/container-instance"
      "Layer"     = "application"
    }
  )

  # Resource group details
  resource_group_name = var.resource_group_id != null ? split("/", var.resource_group_id)[4] : var.resource_group_name
  resource_group_id   = var.resource_group_id != null ? var.resource_group_id : data.azurerm_resource_group.container_instance[0].id

  # Container group name with optional naming convention
  container_group_name = var.use_naming_convention ? "aci-${var.name}-${var.environment}-${var.location_short}" : var.name

  # Network configuration
  is_private_deployment = var.subnet_id != null
  enable_public_ip      = var.ip_address_type == "Public" && !local.is_private_deployment

  # DNS configuration
  dns_name_label = var.dns_name_label != null ? var.dns_name_label : (
    var.enable_dns_name_generation ? "${local.container_group_name}-${random_string.dns_suffix[0].result}" : null
  )

  # Ports configuration
  exposed_ports = var.ip_address_type == "Public" ? var.exposed_ports : []
}

# Random string for DNS name generation
resource "random_string" "dns_suffix" {
  count   = var.enable_dns_name_generation ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# Log Analytics Workspace for container monitoring
resource "azurerm_log_analytics_workspace" "container_logs" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${local.container_group_name}-logs"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  tags = local.common_tags
}

# Container Registry credentials (if using private registry)
data "azurerm_container_registry" "acr" {
  count               = var.container_registry_name != null ? 1 : 0
  name                = var.container_registry_name
  resource_group_name = var.container_registry_resource_group != null ? var.container_registry_resource_group : local.resource_group_name
}

# Container Group
resource "azurerm_container_group" "main" {
  name                = local.container_group_name
  location            = var.location
  resource_group_name = local.resource_group_name
  ip_address_type     = var.ip_address_type
  dns_name_label      = local.dns_name_label
  os_type             = var.os_type
  restart_policy      = var.restart_policy
  subnet_ids          = var.subnet_id != null ? [var.subnet_id] : null

  # Image registry credentials
  dynamic "image_registry_credential" {
    for_each = var.container_registry_name != null ? [1] : []
    content {
      server   = data.azurerm_container_registry.acr[0].login_server
      username = var.container_registry_username != null ? var.container_registry_username : data.azurerm_container_registry.acr[0].admin_username
      password = var.container_registry_password != null ? var.container_registry_password : data.azurerm_container_registry.acr[0].admin_password
    }
  }

  # Additional image registry credentials
  dynamic "image_registry_credential" {
    for_each = var.additional_image_registries
    content {
      server   = image_registry_credential.value.server
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
    }
  }

  # DNS configuration
  dynamic "dns_config" {
    for_each = var.dns_config != null ? [var.dns_config] : []
    content {
      nameservers    = dns_config.value.nameservers
      search_domains = dns_config.value.search_domains
      options        = dns_config.value.options
    }
  }

  # Exposed ports (for public IP)
  dynamic "exposed_port" {
    for_each = local.exposed_ports
    content {
      port     = exposed_port.value.port
      protocol = exposed_port.value.protocol
    }
  }


  # Main container
  container {
    name   = var.containers[0].name
    image  = var.containers[0].image
    cpu    = var.containers[0].cpu
    memory = var.containers[0].memory

    # Ports
    dynamic "ports" {
      for_each = var.containers[0].ports != null ? var.containers[0].ports : []
      content {
        port     = ports.value.port
        protocol = ports.value.protocol
      }
    }

    # Environment variables
    environment_variables = var.containers[0].environment_variables

    # Secure environment variables
    secure_environment_variables = var.containers[0].secure_environment_variables

    # Commands
    commands = var.containers[0].commands


    # Liveness probe
    dynamic "liveness_probe" {
      for_each = var.containers[0].liveness_probe != null ? [var.containers[0].liveness_probe] : []
      content {
        exec                  = liveness_probe.value.exec
        initial_delay_seconds = liveness_probe.value.initial_delay_seconds
        period_seconds        = liveness_probe.value.period_seconds
        failure_threshold     = liveness_probe.value.failure_threshold
        success_threshold     = liveness_probe.value.success_threshold
        timeout_seconds       = liveness_probe.value.timeout_seconds

        dynamic "http_get" {
          for_each = liveness_probe.value.http_get != null ? liveness_probe.value.http_get : []
          content {
            path   = http_get.value.path
            port   = http_get.value.port
            scheme = try(http_get.value.scheme, "HTTP")
          }
        }
      }
    }

    # Readiness probe
    dynamic "readiness_probe" {
      for_each = var.containers[0].readiness_probe != null ? [var.containers[0].readiness_probe] : []
      content {
        exec                  = readiness_probe.value.exec
        initial_delay_seconds = readiness_probe.value.initial_delay_seconds
        period_seconds        = readiness_probe.value.period_seconds
        failure_threshold     = readiness_probe.value.failure_threshold
        success_threshold     = readiness_probe.value.success_threshold
        timeout_seconds       = readiness_probe.value.timeout_seconds

        dynamic "http_get" {
          for_each = readiness_probe.value.http_get != null ? readiness_probe.value.http_get : []
          content {
            path   = http_get.value.path
            port   = http_get.value.port
            scheme = try(http_get.value.scheme, "HTTP")
          }
        }
      }
    }

    # GPU resources
    dynamic "gpu" {
      for_each = var.containers[0].gpu != null ? [var.containers[0].gpu] : []
      content {
        count = gpu.value.count
        sku   = gpu.value.sku
      }
    }
  }

  # Additional containers
  dynamic "container" {
    for_each = length(var.containers) > 1 ? slice(var.containers, 1, length(var.containers)) : []
    content {
      name   = container.value.name
      image  = container.value.image
      cpu    = container.value.cpu
      memory = container.value.memory

      # Ports
      dynamic "ports" {
        for_each = container.value.ports != null ? container.value.ports : []
        content {
          port     = ports.value.port
          protocol = ports.value.protocol
        }
      }

      # Environment variables
      environment_variables = container.value.environment_variables

      # Secure environment variables
      secure_environment_variables = container.value.secure_environment_variables

      # Commands
      commands = container.value.commands


      # Liveness probe
      dynamic "liveness_probe" {
        for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
        content {
          exec                  = liveness_probe.value.exec
          initial_delay_seconds = liveness_probe.value.initial_delay_seconds
          period_seconds        = liveness_probe.value.period_seconds
          failure_threshold     = liveness_probe.value.failure_threshold
          success_threshold     = liveness_probe.value.success_threshold
          timeout_seconds       = liveness_probe.value.timeout_seconds

          dynamic "http_get" {
            for_each = liveness_probe.value.http_get != null ? liveness_probe.value.http_get : []
            content {
              path   = http_get.value.path
              port   = http_get.value.port
              scheme = try(http_get.value.scheme, "HTTP")
            }
          }
        }
      }

      # Readiness probe
      dynamic "readiness_probe" {
        for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
        content {
          exec                  = readiness_probe.value.exec
          initial_delay_seconds = readiness_probe.value.initial_delay_seconds
          period_seconds        = readiness_probe.value.period_seconds
          failure_threshold     = readiness_probe.value.failure_threshold
          success_threshold     = readiness_probe.value.success_threshold
          timeout_seconds       = readiness_probe.value.timeout_seconds

          dynamic "http_get" {
            for_each = readiness_probe.value.http_get != null ? readiness_probe.value.http_get : []
            content {
              path   = http_get.value.path
              port   = http_get.value.port
              scheme = try(http_get.value.scheme, "HTTP")
            }
          }
        }
      }

      # GPU resources
      dynamic "gpu" {
        for_each = container.value.gpu != null ? [container.value.gpu] : []
        content {
          count = gpu.value.count
          sku   = gpu.value.sku
        }
      }
    }
  }

  # Diagnostics configuration
  dynamic "diagnostics" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      log_analytics {
        workspace_id  = azurerm_log_analytics_workspace.container_logs[0].workspace_id
        workspace_key = azurerm_log_analytics_workspace.container_logs[0].primary_shared_key
      }
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.managed_identity != null ? [var.managed_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }


  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by Azure policies
      tags["CreatedBy"],
      tags["CreatedDate"],
    ]
  }
}

# Container monitoring alerts
resource "azurerm_monitor_metric_alert" "container_cpu" {
  count               = var.enable_monitoring && var.cpu_alert_threshold > 0 ? 1 : 0
  name                = "${local.container_group_name}-cpu-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_container_group.main.id]

  description = "Alert when container CPU usage exceeds threshold"
  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 2

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "container_memory" {
  count               = var.enable_monitoring && var.memory_alert_threshold > 0 ? 1 : 0
  name                = "${local.container_group_name}-memory-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_container_group.main.id]

  description = "Alert when container memory usage exceeds threshold"
  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 2

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "MemoryUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}