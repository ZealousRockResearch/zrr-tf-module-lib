# azure-infrastructure-resource-group module
# Description: Manages Azure Resource Groups with enterprise standards and tagging

# Data sources
data "azurerm_subscription" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.resource_group_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/resource-group"
      "Layer"     = "infrastructure"
    }
  )

  # Construct resource group name with naming convention
  resource_group_name = var.use_naming_convention ? "rg-${var.environment}-${var.name}-${var.location_short}" : var.name

  # Default budget start date (first day of current month, or user-specified)
  # Uses a fixed date when budget_start_date is not provided to ensure idempotency
  budget_start_date = var.budget_start_date != "" ? var.budget_start_date : "2025-09-01T00:00:00Z"
}

# Resources
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags

  # Note: prevent_destroy cannot use variables in Terraform
  # To enable destroy protection, uncomment the following:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Resource locks (optional)
resource "azurerm_management_lock" "resource_group_lock" {
  count = var.enable_resource_lock ? 1 : 0

  name       = "${azurerm_resource_group.main.name}-lock"
  scope      = azurerm_resource_group.main.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

# Budget alert (optional)
resource "azurerm_consumption_budget_resource_group" "budget" {
  count = var.enable_budget_alert ? 1 : 0

  name              = "${azurerm_resource_group.main.name}-budget"
  resource_group_id = azurerm_resource_group.main.id

  amount     = var.budget_amount
  time_grain = var.budget_time_grain

  time_period {
    start_date = local.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = var.budget_threshold_percentage
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = var.budget_contact_emails
  }

}