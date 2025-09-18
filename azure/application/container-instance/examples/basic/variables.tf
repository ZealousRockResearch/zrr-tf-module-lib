variable "container_name" {
  description = "Name of the container instance group"
  type        = string
  default     = "basic-container-example"
}

variable "location" {
  description = "Azure region for the container instance"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "container-basic-rg"
}

# Container configuration
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
      name   = "nginx-web"
      image  = "nginx:latest"
      cpu    = 1
      memory = 1.5
      ports = [
        {
          port     = 80
          protocol = "TCP"
        }
      ]
      environment_variables = {
        NGINX_PORT = "80"
      }
    }
  ]
}

# Network configuration
variable "ip_address_type" {
  description = "IP address type for the container group"
  type        = string
  default     = "Public"
}

variable "exposed_ports" {
  description = "List of ports to expose for public access"
  type = list(object({
    port     = number
    protocol = string
  }))
  default = [
    {
      port     = 80
      protocol = "TCP"
    }
  ]
}

variable "dns_name_label" {
  description = "DNS name label for the container group"
  type        = string
  default     = "basic-container-demo"
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

# Tags
variable "common_tags" {
  description = "Common tags for the basic example"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "container-basic-example"
    Owner       = "platform-team"
    ManagedBy   = "Terraform"
  }
}

variable "container_instance_tags" {
  description = "Additional tags for the container instance"
  type        = map(string)
  default = {
    Application = "web-server"
    Purpose     = "basic-example"
    Monitoring  = "disabled"
    Network     = "public"
  }
}