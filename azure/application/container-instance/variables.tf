# Required variables
variable "name" {
  description = "Name of the container instance group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "Container instance name must be 1-64 characters long, start and end with alphanumeric characters, and contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  description = "Azure region for the container instance"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
      "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope",
      "uksouth", "ukwest", "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth",
      "uaenorth", "southafricanorth", "australiaeast", "australiasoutheast", "eastasia", "southeastasia",
      "japaneast", "japanwest", "koreacentral", "koreasouth", "centralindia", "southindia", "westindia"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the container instance will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,90}$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters long and contain only alphanumeric characters, periods, underscores, and hyphens."
  }
}

# Optional resource group ID (takes precedence over resource_group_name)
variable "resource_group_id" {
  description = "Resource ID of an existing resource group (takes precedence over resource_group_name)"
  type        = string
  default     = null

  validation {
    condition     = var.resource_group_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "Resource group ID must be a valid Azure resource ID format."
  }
}

# Container configuration
variable "containers" {
  description = "List of containers to run in the container group"
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

  validation {
    condition     = length(var.containers) > 0 && length(var.containers) <= 60
    error_message = "At least one container must be specified, and no more than 60 containers are allowed per container group."
  }

  validation {
    condition = alltrue([
      for container in var.containers : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", container.name))
    ])
    error_message = "Container names must be 1-64 characters long, start and end with alphanumeric characters."
  }

  validation {
    condition = alltrue([
      for container in var.containers : container.cpu >= 0.1 && container.cpu <= 4
    ])
    error_message = "Container CPU must be between 0.1 and 4 cores."
  }

  validation {
    condition = alltrue([
      for container in var.containers : container.memory >= 0.1 && container.memory <= 16
    ])
    error_message = "Container memory must be between 0.1 and 16 GB."
  }
}

# Network configuration
variable "ip_address_type" {
  description = "IP address type for the container group"
  type        = string
  default     = "Public"

  validation {
    condition     = contains(["Public", "Private", "None"], var.ip_address_type)
    error_message = "IP address type must be 'Public', 'Private', or 'None'."
  }
}

variable "subnet_id" {
  description = "Subnet ID for private container deployment"
  type        = string
  default     = null

  validation {
    condition     = var.subnet_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure subnet resource ID."
  }
}

variable "dns_name_label" {
  description = "DNS name label for the container group"
  type        = string
  default     = null

  validation {
    condition     = var.dns_name_label == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.dns_name_label))
    error_message = "DNS name label must be 1-64 characters long, start and end with alphanumeric characters."
  }
}

variable "enable_dns_name_generation" {
  description = "Enable automatic DNS name generation"
  type        = bool
  default     = false
}

variable "exposed_ports" {
  description = "List of ports to expose for public access"
  type = list(object({
    port     = number
    protocol = string
  }))
  default = []

  validation {
    condition = alltrue([
      for port in var.exposed_ports : port.port >= 1 && port.port <= 65535
    ])
    error_message = "Port numbers must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for port in var.exposed_ports : contains(["TCP", "UDP"], port.protocol)
    ])
    error_message = "Protocol must be either 'TCP' or 'UDP'."
  }
}

# DNS configuration
variable "dns_config" {
  description = "DNS configuration for the container group"
  type = object({
    nameservers    = list(string)
    search_domains = optional(list(string), [])
    options        = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.dns_config == null || (
      length(var.dns_config.nameservers) >= 1 && length(var.dns_config.nameservers) <= 5
    )
    error_message = "DNS configuration must have between 1 and 5 nameservers."
  }
}

# OS and runtime configuration
variable "os_type" {
  description = "Operating system type for the container group"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "restart_policy" {
  description = "Restart policy for the container group"
  type        = string
  default     = "Always"

  validation {
    condition     = contains(["Always", "Never", "OnFailure"], var.restart_policy)
    error_message = "Restart policy must be 'Always', 'Never', or 'OnFailure'."
  }
}

# Container registry configuration
variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = null

  validation {
    condition     = var.container_registry_name == null || can(regex("^[a-zA-Z0-9]{5,50}$", var.container_registry_name))
    error_message = "Container registry name must be 5-50 characters long and contain only alphanumeric characters."
  }
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
  default   = []
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
  default = []

  validation {
    condition = alltrue([
      for volume in var.volumes : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", volume.name))
    ])
    error_message = "Volume names must be 1-64 characters long, start and end with alphanumeric characters."
  }
}

# Identity configuration
variable "managed_identity" {
  description = "Managed identity configuration for the container group"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.managed_identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.managed_identity.type)
    error_message = "Managed identity type must be 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

# Monitoring and alerting
variable "enable_monitoring" {
  description = "Enable container monitoring and alerting"
  type        = bool
  default     = false
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "PerGB2018", "Premium", "Standalone", "Standard"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, PerNode, PerGB2018, Premium, Standalone, Standard."
  }
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

variable "action_group_id" {
  description = "Azure Monitor Action Group ID for alerts"
  type        = string
  default     = null

  validation {
    condition     = var.action_group_id == null || can(regex("^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/microsoft.insights/actionGroups/[^/]+$", var.action_group_id))
    error_message = "Action group ID must be a valid Azure resource ID format."
  }
}

variable "cpu_alert_threshold" {
  description = "CPU usage alert threshold (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alert_threshold >= 0 && var.cpu_alert_threshold <= 100
    error_message = "CPU alert threshold must be between 0 and 100."
  }
}

variable "memory_alert_threshold" {
  description = "Memory usage alert threshold (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_alert_threshold >= 0 && var.memory_alert_threshold <= 100
    error_message = "Memory alert threshold must be between 0 and 100."
  }
}

# Naming convention
variable "use_naming_convention" {
  description = "Use ZRR naming convention for container instance name"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for naming convention"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,10}$", var.environment))
    error_message = "Environment must be 1-10 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location_short" {
  description = "Short location code for naming convention"
  type        = string
  default     = "eus"

  validation {
    condition     = can(regex("^[a-z]{2,5}$", var.location_short))
    error_message = "Location short must be 2-5 lowercase letters."
  }
}

# Common tags (required for all modules)
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "zrr"
    ManagedBy   = "Terraform"
  }

  validation {
    condition     = can(var.common_tags["Environment"]) && can(var.common_tags["Project"])
    error_message = "Common tags must include 'Environment' and 'Project' keys."
  }
}

# Container instance specific tags
variable "container_instance_tags" {
  description = "Additional tags specific to the container instance"
  type        = map(string)
  default     = {}
}