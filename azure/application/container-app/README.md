# Azure Container App Module

This module creates an Azure Container App with comprehensive configuration options including ingress, scaling, secrets, and container registry integration.

## Features

- ✅ Container App with multiple container support
- ✅ Automatic HTTPS ingress with custom domains
- ✅ Auto-scaling with HTTP, custom, TCP, and Azure Queue triggers
- ✅ Container registry integration (ACR and external)
- ✅ Secrets management with Key Vault integration
- ✅ Health probes (liveness, readiness, startup)
- ✅ Volume mounting and storage integration
- ✅ Dapr integration for microservices
- ✅ Identity management (System/User assigned)
- ✅ Traffic splitting and blue-green deployments

## Usage

### Basic Web Application

```hcl
module "container_app" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/application/container-app?ref=master"

  name                         = "my-web-app"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  containers = [
    {
      name   = "web"
      image  = "nginx:alpine"
      cpu    = 0.25
      memory = "0.5Gi"

      env = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        }
      ]
    }
  ]

  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [
      {
        percentage = 100
      }
    ]
  }

  min_replicas = 1
  max_replicas = 5

  common_tags = {
    Application = "WebApp"
    Environment = "prod"
  }
}
```

### With Azure Container Registry

```hcl
module "container_app" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/application/container-app?ref=master"

  name                         = "ghost-blog"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  # Container Registry integration
  container_registry_name           = azurerm_container_registry.main.name
  container_registry_resource_group = azurerm_resource_group.main.name

  containers = [
    {
      name   = "ghost"
      image  = "${azurerm_container_registry.main.login_server}/ghost:5-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name        = "database__connection__password"
          secret_name = "db-password"
        }
      ]

      liveness_probe = {
        transport = "HTTP"
        port      = 2368
        path      = "/"
        interval_seconds = 30
        timeout = 5
      }
    }
  ]

  ingress = {
    external_enabled = true
    target_port      = 2368
    traffic_weight = [
      {
        percentage = 100
      }
    ]
  }

  secrets = [
    {
      name  = "acr-password"
      value = azurerm_container_registry.main.admin_password
    },
    {
      name  = "db-password"
      value = var.database_password
    }
  ]

  http_scale_rules = [
    {
      name                = "http-requests"
      concurrent_requests = 100
    }
  ]

  common_tags = {
    Application = "GhostBlog"
    Environment = "prod"
  }
}
```

### With Custom Domains and SSL

```hcl
module "container_app" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/application/container-app?ref=master"

  name                         = "custom-domain-app"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  containers = [
    {
      name   = "web"
      image  = "myapp:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  ]

  ingress = {
    external_enabled = true
    target_port      = 8080

    traffic_weight = [
      {
        percentage = 100
      }
    ]

    custom_domains = [
      {
        name           = "blog.mycompany.com"
        binding_type   = "SniEnabled"
        certificate_id = azurerm_container_app_environment_certificate.ssl.id
      }
    ]

    ip_security_restrictions = [
      {
        name             = "office-ip"
        ip_address_range = "203.0.113.0/24"
        action           = "Allow"
        description      = "Office network"
      }
    ]
  }
}
```

### With Dapr Integration

```hcl
module "container_app" {
  source = "git::https://github.com/ZealousRockResearch/zrr-tf-module-lib.git//azure/application/container-app?ref=master"

  name                         = "dapr-microservice"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  containers = [
    {
      name   = "api"
      image  = "myapi:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  ]

  dapr = {
    app_id       = "my-api"
    app_port     = 3000
    app_protocol = "http"
  }

  ingress = {
    external_enabled = false  # Internal only
    target_port      = 3000
    traffic_weight = [
      {
        percentage = 100
      }
    ]
  }

  min_replicas = 0  # Scale to zero when not in use
  max_replicas = 10
}
```

## Input Variables

### Required Variables

| Variable | Description | Type |
|----------|-------------|------|
| `name` | Container App name (2-32 chars, lowercase) | `string` |
| `resource_group_name` | Resource group name | `string` |
| `container_app_environment_id` | Container App Environment ID | `string` |
| `containers` | List of container configurations | `list(object)` |

### Container Configuration

Each container in the `containers` list supports:

```hcl
{
  name   = "container-name"        # Required
  image  = "nginx:alpine"          # Required
  cpu    = 0.25                    # Required (0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)
  memory = "0.5Gi"                # Required (0.5Gi, 1Gi, 1.5Gi, 2Gi, etc.)

  args    = ["--config", "/app/config.yaml"]    # Optional
  command = ["/app/myapp"]                      # Optional

  env = [                         # Optional environment variables
    {
      name  = "ENV_VAR"
      value = "value"
    },
    {
      name        = "SECRET_VAR"
      secret_name = "my-secret"
    }
  ]

  # Health probes (optional)
  liveness_probe = {
    transport    = "HTTP"          # HTTP, TCP, or GRPC
    port        = 80
    path        = "/health"        # For HTTP only
    interval_seconds = 10
    timeout     = 1
    failure_count_threshold = 3
  }

  readiness_probe = { /* same as liveness_probe */ }
  startup_probe   = { /* same as liveness_probe */ }
}
```

### Ingress Configuration

```hcl
ingress = {
  external_enabled          = true              # Public internet access
  target_port              = 80                # Container port
  exposed_port             = 80                # External port (optional)
  allow_insecure_connections = false           # Allow HTTP
  transport                = "auto"            # auto, http, http2, tcp

  traffic_weight = [
    {
      percentage      = 100
      latest_revision = true
    }
  ]

  # Custom domains (optional)
  custom_domains = [
    {
      name           = "api.mycompany.com"
      binding_type   = "SniEnabled"
      certificate_id = "/subscriptions/.../certificates/my-cert"
    }
  ]
}
```

### Scaling Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `min_replicas` | Minimum replicas (0-1000) | `0` |
| `max_replicas` | Maximum replicas (1-1000) | `10` |
| `http_scale_rules` | HTTP-based scaling rules | `[]` |
| `custom_scale_rules` | Custom scaling rules (KEDA) | `[]` |

## Outputs

| Output | Description |
|--------|-------------|
| `application_url` | HTTPS URL of the application |
| `fqdn` | Fully qualified domain name |
| `latest_revision_name` | Name of the latest revision |
| `outbound_ip_addresses` | List of outbound IPs |
| `connection_info` | Complete connection information |

## Common Patterns

### Environment Variables Priority

1. **Plain values**: Direct string values
2. **Secrets**: Reference to Container App secrets
3. **Key Vault**: Automatic secret injection

### Health Probes Best Practices

```hcl
liveness_probe = {
  transport               = "HTTP"
  port                   = 8080
  path                   = "/health/live"
  interval_seconds       = 30
  timeout                = 5
  failure_count_threshold = 3
  initial_delay          = 30
}

readiness_probe = {
  transport               = "HTTP"
  port                   = 8080
  path                   = "/health/ready"
  interval_seconds       = 10
  timeout                = 1
  failure_count_threshold = 3
}
```

### Scaling Rules Examples

```hcl
# Scale based on HTTP requests
http_scale_rules = [
  {
    name                = "http-requests"
    concurrent_requests = 50
  }
]

# Scale based on Azure Service Bus queue
custom_scale_rules = [
  {
    name             = "servicebus-queue"
    custom_rule_type = "azure-servicebus"
    metadata = [
      {
        name  = "queueName"
        value = "my-queue"
      },
      {
        name  = "messageCount"
        value = "5"
      }
    ]
  }
]
```

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.108
- Container App Environment must exist
- For ACR: Container registry admin user enabled or managed identity

## Cost Optimization

- Set `min_replicas = 0` for development environments
- Use appropriate CPU/memory sizes for your workload
- Monitor scaling metrics to optimize thresholds
- Consider reserved capacity for predictable workloads