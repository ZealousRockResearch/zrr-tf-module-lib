# azure-security-key-vault module
# Description: Azure Key Vault module for managing secrets, keys, and certificates in a security layer

# Data sources
data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.key_vault_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/security/key-vault"
      "Layer"     = "security"
    }
  )
}

# Resource Group (if not provided)
resource "azurerm_resource_group" "main" {
  count = var.resource_group_name == null ? 1 : 0

  name     = "${var.name}-rg"
  location = var.location

  tags = local.common_tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : azurerm_resource_group.main[0].name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = var.sku_name

  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  tags = local.common_tags
}

# Access Policies
resource "azurerm_key_vault_access_policy" "main" {
  for_each = var.access_policies

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
}

# Secrets
resource "azurerm_key_vault_secret" "main" {
  for_each = var.secrets

  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.main.id

  content_type    = try(each.value.content_type, null)
  expiration_date = try(each.value.expiration_date, null)
  not_before_date = try(each.value.not_before_date, null)

  tags = merge(local.common_tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.main]
}

# Keys
resource "azurerm_key_vault_key" "main" {
  for_each = var.keys

  name         = each.key
  key_vault_id = azurerm_key_vault.main.id
  key_type     = each.value.key_type
  key_size     = try(each.value.key_size, null)
  curve        = try(each.value.curve, null)

  key_opts = each.value.key_opts

  expiration_date = try(each.value.expiration_date, null)
  not_before_date = try(each.value.not_before_date, null)

  tags = merge(local.common_tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.main]
}

# Private Endpoint (if specified)
resource "azurerm_private_endpoint" "main" {
  count = var.private_endpoint != null ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : azurerm_resource_group.main[0].name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "${var.name}-dns-zone-group"
      private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
    }
  }

  tags = local.common_tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.diagnostic_setting != null ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.diagnostic_setting.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_setting.storage_account_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_setting.metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}