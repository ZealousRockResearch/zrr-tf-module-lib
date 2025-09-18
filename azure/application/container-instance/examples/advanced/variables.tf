variable "container_name" {
  description = "Name of the container instance group"
  type        = string
  default     = "advanced-microservices-app"
}

variable "location" {
  description = "Azure region for the container instance"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "container-advanced-rg"
}

# Advanced multi-container configuration
variable "containers" {
  description = "List of containers to deploy"
  type = list(object({
    name   = string
    image  = string
    cpu    = number
    memory = number
    ports = optional(list(object({
      port     = number
      protocol = optional(string, "TCP")
    })), [])
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
    commands                     = optional(list(string), [])
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      read_only  = optional(bool, false)
    })), [])
    liveness_probe = optional(object({
      exec = optional(list(string))
      http_get = optional(list(object({
        path   = optional(string)
        port   = number
        scheme = optional(string, "HTTP")
      })))
      initial_delay_seconds = optional(number, 30)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
      success_threshold     = optional(number, 1)
      timeout_seconds       = optional(number, 1)
    }))
    readiness_probe = optional(object({
      exec = optional(list(string))
      http_get = optional(list(object({
        path   = optional(string)
        port   = number
        scheme = optional(string, "HTTP")
      })))
      initial_delay_seconds = optional(number, 0)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
      success_threshold     = optional(number, 1)
      timeout_seconds       = optional(number, 1)
    }))
    gpu = optional(object({
      count = number
      sku   = string
    }))
  }))
  default = [
    {
      name   = "frontend"
      image  = "nginx:latest"
      cpu    = 1
      memory = 2
      ports = [
        {
          port     = 3000
          protocol = "TCP"
        }
      ]
      environment_variables = {
        NODE_ENV = "production"
        API_URL  = "http://localhost:8080"
        PORT     = "3000"
      }
      liveness_probe = {
        http_get = [
          {
            path = "/health"
            port = 3000
          }
        ]
        initial_delay_seconds = 30
        period_seconds        = 10
        failure_threshold     = 3
      }
      readiness_probe = {
        http_get = [
          {
            path = "/ready"
            port = 3000
          }
        ]
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 3
      }
      volume_mounts = [
        {
          name       = "shared-config"
          mount_path = "/app/config"
          read_only  = true
        }
      ]
    },
    {
      name   = "backend"
      image  = "node:16-alpine"
      cpu    = 0.5
      memory = 1
      ports = [
        {
          port     = 8080
          protocol = "TCP"
        }
      ]
      environment_variables = {
        NODE_ENV = "production"
        PORT     = "8080"
      }
      secure_environment_variables = {
        DATABASE_PASSWORD = "secure-db-password"
        API_SECRET_KEY    = "super-secret-key"
        JWT_SECRET        = "jwt-signing-secret"
      }
      commands = ["node", "server.js"]
      volume_mounts = [
        {
          name       = "app-data"
          mount_path = "/app/data"
          read_only  = false
        },
        {
          name       = "shared-config"
          mount_path = "/app/config"
          read_only  = true
        }
      ]
      liveness_probe = {
        http_get = [
          {
            path = "/api/health"
            port = 8080
          }
        ]
        initial_delay_seconds = 45
        period_seconds        = 15
        failure_threshold     = 3
      }
    },
    {
      name   = "sidecar-logger"
      image  = "fluent/fluent-bit:latest"
      cpu    = 0.1
      memory = 0.25
      environment_variables = {
        FLUENT_CONF = "fluent-bit.conf"
        LOG_LEVEL   = "info"
      }
      volume_mounts = [
        {
          name       = "log-config"
          mount_path = "/fluent-bit/etc"
          read_only  = true
        },
        {
          name       = "app-logs"
          mount_path = "/var/log/app"
          read_only  = true
        }
      ]
    }
  ]
}

# Network configuration
variable "ip_address_type" {
  description = "IP address type for the container group"
  type        = string
  default     = "Private"
}

variable "subnet_id" {
  description = "Subnet ID for private container deployment"
  type        = string
  default     = null
}

variable "exposed_ports" {
  description = "List of ports to expose for public access"
  type = list(object({
    port     = number
    protocol = string
  }))
  default = [
    {
      port     = 3000
      protocol = "TCP"
    },
    {
      port     = 8080
      protocol = "TCP"
    }
  ]
}

variable "dns_name_label" {
  description = "DNS name label for the container group"
  type        = string
  default     = null
}

variable "dns_config" {
  description = "DNS configuration for the container group"
  type = object({
    nameservers    = list(string)
    search_domains = optional(list(string), [])
    options        = optional(list(string), [])
  })
  default = {
    nameservers    = ["8.8.8.8", "8.8.4.4"]
    search_domains = ["internal.company.com"]
    options        = ["ndots:2", "edns0"]
  }
}

# OS and runtime configuration
variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "Linux"
}

variable "restart_policy" {
  description = "Restart policy for containers"
  type        = string
  default     = "Always"
}

# Container registry configuration
variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = null
}

variable "container_registry_resource_group" {
  description = "Resource group name of the Azure Container Registry"
  type        = string
  default     = null
}

variable "container_registry_username" {
  description = "Username for container registry authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "container_registry_password" {
  description = "Password for container registry authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "additional_image_registries" {
  description = "Additional image registries for authentication"
  type = list(object({
    server   = string
    username = string
    password = string
  }))
  default = [
    {
      server   = "docker.io"
      username = "dockerhub-user"
      password = "dockerhub-token"
    }
  ]
  sensitive = true
}

# Volume configuration
variable "volumes" {
  description = "List of volumes to mount in the container group"
  type = list(object({
    name                 = string
    mount_path           = optional(string)
    read_only            = optional(bool, false)
    empty_dir            = optional(bool, false)
    storage_account_name = optional(string)
    storage_account_key  = optional(string)
    share_name           = optional(string)
    git_repo = optional(object({
      url       = string
      directory = optional(string)
      revision  = optional(string)
    }))
    secret = optional(map(string), {})
  }))
  default = [
    {
      name                 = "app-data"
      storage_account_name = "mystorageaccount"
      storage_account_key  = "storage-account-key"
      share_name           = "app-data-share"
    },
    {
      name      = "shared-config"
      empty_dir = true
    },
    {
      name = "app-source"
      git_repo = {
        url       = "https://github.com/company/microservices-config.git"
        directory = "config"
        revision  = "main"
      }
    },
    {
      name = "app-secrets"
      secret = {
        "database.json" = "eyJob3N0IjoiZGIuZXhhbXBsZS5jb20iLCJ1c2VyIjoiYXBwIn0="
        "api-keys.json" = "eyJhcGlfa2V5IjoiYWJjMTIzIiwic2VjcmV0IjoieHl6Nzg5In0="
      }
    },
    {
      name = "log-config"
      secret = {
        "fluent-bit.conf" = "W0lOUFVUXQogICAgTmFtZSB0YWlsCiAgICBQYXRoIC92YXIvbG9nL2FwcC8qLmxvZw=="
      }
    },
    {
      name      = "app-logs"
      empty_dir = true
    }
  ]
}

# Identity configuration
variable "managed_identity" {
  description = "Managed identity configuration for the container group"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type = "SystemAssigned"
  }
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable container monitoring and alerting"
  type        = bool
  default     = true
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 90
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID for alerts"
  type        = string
  default     = null
}

variable "cpu_alert_threshold" {
  description = "CPU usage alert threshold (percentage)"
  type        = number
  default     = 80
}

variable "memory_alert_threshold" {
  description = "Memory usage alert threshold (percentage)"
  type        = number
  default     = 85
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention for container instance name"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name for naming convention"
  type        = string
  default     = "prod"
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"
}

# Tags
variable "common_tags" {
  description = "Common tags for the advanced example"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "microservices-platform"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Compliance  = "SOX"
    ManagedBy   = "Terraform"
  }
}

variable "container_instance_tags" {
  description = "Additional tags for the container instance"
  type        = map(string)
  default = {
    Application  = "microservices"
    Purpose      = "production-workload"
    Monitoring   = "enabled"
    Network      = "private"
    Storage      = "persistent"
    Identity     = "managed"
    Registry     = "private"
    HealthChecks = "enabled"
    Logging      = "centralized"
    Architecture = "multi-container"
    Scalability  = "horizontal"
    Security     = "enhanced"
  }
}