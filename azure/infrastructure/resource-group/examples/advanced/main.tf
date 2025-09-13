module "production_resource_group" {
  source = "../../"

  name                  = "critical-production-app"
  location              = var.location
  environment           = "prod"
  location_short        = var.location_short
  use_naming_convention = true

  # Enable resource lock for production resources (provides delete protection)
  enable_resource_lock = true
  lock_level           = "CanNotDelete"
  lock_notes           = "Production resource group - requires change approval for deletion"

  # Enable budget monitoring
  enable_budget_alert         = true
  budget_amount               = var.budget_amount
  budget_time_grain           = "Monthly"
  budget_threshold_percentage = 80
  budget_contact_emails       = var.budget_contact_emails

  common_tags = var.common_tags

  resource_group_tags = merge(
    var.additional_tags,
    {
      Criticality = "High"
      DataClass   = "Confidential"
      Compliance  = "PCI-DSS"
    }
  )
}

# Secondary resource group for disaster recovery
module "dr_resource_group" {
  source = "../../"

  name                  = "critical-production-app-dr"
  location              = var.dr_location
  environment           = "dr"
  location_short        = var.dr_location_short
  use_naming_convention = true

  # Enable resource lock for DR (provides delete protection)
  enable_resource_lock = true
  lock_level           = "CanNotDelete"
  lock_notes           = "DR resource group - requires change approval for deletion"

  # Enable budget monitoring for DR (lower threshold)
  enable_budget_alert         = true
  budget_amount               = var.dr_budget_amount
  budget_time_grain           = "Monthly"
  budget_threshold_percentage = 90
  budget_contact_emails       = var.budget_contact_emails

  common_tags = merge(
    var.common_tags,
    {
      Environment = "dr"
      ReplicaOf   = module.production_resource_group.name
    }
  )

  resource_group_tags = merge(
    var.additional_tags,
    {
      Criticality = "High"
      DataClass   = "Confidential"
      Compliance  = "PCI-DSS"
      Purpose     = "DisasterRecovery"
    }
  )
}

# Outputs for production resource group
output "production_resource_group" {
  description = "Production resource group details"
  value = {
    id       = module.production_resource_group.id
    name     = module.production_resource_group.name
    location = module.production_resource_group.location
    urn      = module.production_resource_group.resource_group_urn
    locked   = module.production_resource_group.is_locked
    budget   = module.production_resource_group.has_budget_alert
  }
}

# Outputs for DR resource group
output "dr_resource_group" {
  description = "Disaster recovery resource group details"
  value = {
    id       = module.dr_resource_group.id
    name     = module.dr_resource_group.name
    location = module.dr_resource_group.location
    urn      = module.dr_resource_group.resource_group_urn
    locked   = module.dr_resource_group.is_locked
    budget   = module.dr_resource_group.has_budget_alert
  }
}

# Combined output for both resource groups
output "resource_groups_summary" {
  description = "Summary of all resource groups"
  value = {
    production = {
      name          = module.production_resource_group.name
      location      = module.production_resource_group.location
      budget_amount = module.production_resource_group.budget_amount
      lock_level    = module.production_resource_group.lock_level
    }
    disaster_recovery = {
      name          = module.dr_resource_group.name
      location      = module.dr_resource_group.location
      budget_amount = module.dr_resource_group.budget_amount
      lock_level    = module.dr_resource_group.lock_level
    }
    total_budget = coalesce(module.production_resource_group.budget_amount, 0) + coalesce(module.dr_resource_group.budget_amount, 0)
  }
}

# Subscription information
output "subscription_info" {
  description = "Azure subscription information"
  value = {
    subscription_id = module.production_resource_group.subscription_id
    tenant_id       = module.production_resource_group.tenant_id
  }
}