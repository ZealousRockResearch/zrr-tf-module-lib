# Compliance Container Outputs
output "compliance_container_id" {
  description = "The ID of the compliance container"
  value       = module.compliance_container.id
}

output "compliance_container_url" {
  description = "The URL of the compliance container"
  value       = module.compliance_container.container_url
}

output "compliance_security_features" {
  description = "Security features enabled on the compliance container"
  value       = module.compliance_container.security_features
}

output "compliance_legal_hold_status" {
  description = "Legal hold status for compliance container"
  value = {
    enabled = module.compliance_container.legal_hold_enabled
    tags    = module.compliance_container.legal_hold_tags
  }
}

output "compliance_immutability_status" {
  description = "Immutability policy status for compliance container"
  value = {
    enabled     = module.compliance_container.immutability_policy_enabled
    period_days = module.compliance_container.immutability_period_days
    locked      = module.compliance_container.immutability_policy_locked
  }
}

# Application Data Container Outputs
output "app_data_container_id" {
  description = "The ID of the application data container"
  value       = module.application_data_container.id
}

output "app_data_container_url" {
  description = "The URL of the application data container"
  value       = module.application_data_container.container_url
}

output "app_data_lifecycle_rules" {
  description = "Number of lifecycle rules configured for app data container"
  value       = module.application_data_container.lifecycle_rules_count
}

# Backup Container Outputs
output "backup_container_id" {
  description = "The ID of the backup container"
  value       = module.backup_container.id
}

output "backup_container_url" {
  description = "The URL of the backup container"
  value       = module.backup_container.container_url
}

output "backup_lifecycle_rules" {
  description = "Number of lifecycle rules configured for backup container"
  value       = module.backup_container.lifecycle_rules_count
}

# Summary Outputs
output "containers_summary" {
  description = "Summary of all created containers"
  value = {
    compliance = {
      name              = module.compliance_container.name
      url               = module.compliance_container.container_url
      security_features = module.compliance_container.security_features
    }
    app_data = {
      name            = module.application_data_container.name
      url             = module.application_data_container.container_url
      lifecycle_rules = module.application_data_container.lifecycle_rules_count
    }
    backup = {
      name            = module.backup_container.name
      url             = module.backup_container.container_url
      lifecycle_rules = module.backup_container.lifecycle_rules_count
    }
  }
}

output "management_policies" {
  description = "Management policy IDs for all containers"
  value = {
    compliance = module.compliance_container.management_policy_id
    app_data   = module.application_data_container.management_policy_id
    backup     = module.backup_container.management_policy_id
  }
}