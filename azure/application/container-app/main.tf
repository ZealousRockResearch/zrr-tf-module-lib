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

data "azurerm_container_registry" "acr" {
  count               = var.container_registry_name != null ? 1 : 0
  name                = var.container_registry_name
  resource_group_name = var.container_registry_resource_group
}

# Container App
resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name

  # Template configuration
  template {
    # Container configuration
    dynamic "container" {
      for_each = var.containers
      content {
        name   = container.value.name
        image  = container.value.image
        cpu    = container.value.cpu
        memory = container.value.memory
        args   = container.value.args
        command = container.value.command

        # Environment variables
        dynamic "env" {
          for_each = container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        # Volume mounts
        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }

        # Liveness probe
        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
          content {
            transport                     = liveness_probe.value.transport
            port                         = liveness_probe.value.port
            path                         = liveness_probe.value.path
            host                         = liveness_probe.value.host
            interval_seconds             = liveness_probe.value.interval_seconds
            timeout                      = liveness_probe.value.timeout
            failure_count_threshold      = liveness_probe.value.failure_count_threshold
            initial_delay                = liveness_probe.value.initial_delay

            dynamic "header" {
              for_each = liveness_probe.value.headers
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        # Readiness probe
        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
          content {
            transport                     = readiness_probe.value.transport
            port                         = readiness_probe.value.port
            path                         = readiness_probe.value.path
            host                         = readiness_probe.value.host
            interval_seconds             = readiness_probe.value.interval_seconds
            timeout                      = readiness_probe.value.timeout
            failure_count_threshold      = readiness_probe.value.failure_count_threshold
            success_count_threshold      = readiness_probe.value.success_count_threshold

            dynamic "header" {
              for_each = readiness_probe.value.headers
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        # Startup probe
        dynamic "startup_probe" {
          for_each = container.value.startup_probe != null ? [container.value.startup_probe] : []
          content {
            transport                     = startup_probe.value.transport
            port                         = startup_probe.value.port
            path                         = startup_probe.value.path
            host                         = startup_probe.value.host
            interval_seconds             = startup_probe.value.interval_seconds
            timeout                      = startup_probe.value.timeout
            failure_count_threshold      = startup_probe.value.failure_count_threshold

            dynamic "header" {
              for_each = startup_probe.value.headers
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
      }
    }

    # Init containers
    dynamic "init_container" {
      for_each = var.init_containers
      content {
        name   = init_container.value.name
        image  = init_container.value.image
        cpu    = init_container.value.cpu
        memory = init_container.value.memory
        args   = init_container.value.args
        command = init_container.value.command

        dynamic "env" {
          for_each = init_container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    # Volumes
    dynamic "volume" {
      for_each = var.volumes
      content {
        name         = volume.value.name
        storage_type = volume.value.storage_type
        storage_name = volume.value.storage_name
      }
    }

    # Scaling
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    # HTTP scaling rules
    dynamic "http_scale_rule" {
      for_each = var.http_scale_rules
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        metadata = {
          for k, v in { for item in http_scale_rule.value.metadata : item.name => item.value } : k => v
        }
      }
    }

    # Custom scaling rules
    dynamic "custom_scale_rule" {
      for_each = var.custom_scale_rules
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type

        metadata = {
          for k, v in { for item in custom_scale_rule.value.metadata : item.name => item.value } : k => v
        }

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    # TCP scaling rules
    dynamic "tcp_scale_rule" {
      for_each = var.tcp_scale_rules
      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        metadata = {
          for k, v in { for item in tcp_scale_rule.value.metadata : item.name => item.value } : k => v
        }

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    # Azure Queue scaling rules
    dynamic "azure_queue_scale_rule" {
      for_each = var.azure_queue_scale_rules
      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    # Revision suffix
    revision_suffix = var.revision_suffix
  }

  # Ingress configuration
  dynamic "ingress" {
    for_each = var.ingress != null ? [var.ingress] : []
    content {
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled          = ingress.value.external_enabled
      target_port               = ingress.value.target_port
      exposed_port              = ingress.value.exposed_port
      transport                 = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight
        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          label           = traffic_weight.value.label
        }
      }

      dynamic "custom_domain" {
        for_each = ingress.value.custom_domains
        content {
          name           = custom_domain.value.name
          certificate_id = custom_domain.value.certificate_id
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restrictions
        content {
          name             = ip_security_restriction.value.name
          ip_address_range = ip_security_restriction.value.ip_address_range
          action           = ip_security_restriction.value.action
          description      = ip_security_restriction.value.description
        }
      }
    }
  }

  # Dapr configuration
  dynamic "dapr" {
    for_each = var.dapr != null ? [var.dapr] : []
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  # Secrets
  dynamic "secret" {
    for_each = var.secrets
    content {
      name                = secret.value.name
      value               = secret.value.value
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
    }
  }

  # Registry credentials
  dynamic "registry" {
    for_each = var.container_registry_name != null ? [1] : []
    content {
      server               = data.azurerm_container_registry.acr[0].login_server
      username             = var.container_registry_username != null ? var.container_registry_username : data.azurerm_container_registry.acr[0].admin_username
      password_secret_name = var.container_registry_password_secret_name
      identity             = var.container_registry_identity
    }
  }

  # Additional registries
  dynamic "registry" {
    for_each = var.additional_registries
    content {
      server               = registry.value.server
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
      identity             = registry.value.identity
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

  tags = merge(
    var.common_tags,
    {
      Module = "zrr-tf-module-lib/azure/application/container-app"
      Layer  = "application"
    },
    var.container_app_tags
  )
}