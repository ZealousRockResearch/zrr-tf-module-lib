# azure-infrastructure-dns-zone module
# Description: Manages Azure DNS Zone with comprehensive enterprise features including record management, delegation, DNSSEC, and monitoring

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "dns_zone" {
  count = var.resource_group_id != null ? 0 : 1
  name  = var.resource_group_name
}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.dns_zone_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/dns-zone"
      "Layer"     = "infrastructure"
    }
  )

  # Resource group details
  resource_group_name = var.resource_group_id != null ? split("/", var.resource_group_id)[4] : var.resource_group_name
  resource_group_id   = var.resource_group_id != null ? var.resource_group_id : data.azurerm_resource_group.dns_zone[0].id

  # DNS zone name with optional naming convention
  dns_zone_name = var.use_naming_convention ? "${var.name}.${var.environment}.${var.domain_suffix}" : var.name

  # Validate zone name format
  is_valid_zone_name = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?))*$", local.dns_zone_name))
}

# DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = local.dns_zone_name
  resource_group_name = local.resource_group_name

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# DNS Records - A Records
resource "azurerm_dns_a_record" "a_records" {
  for_each = { for record in var.a_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl
  records             = each.value.records

  tags = local.common_tags
}

# DNS Records - AAAA Records
resource "azurerm_dns_aaaa_record" "aaaa_records" {
  for_each = { for record in var.aaaa_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl
  records             = each.value.records

  tags = local.common_tags
}

# DNS Records - CNAME Records
resource "azurerm_dns_cname_record" "cname_records" {
  for_each = { for record in var.cname_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl
  record              = each.value.record

  tags = local.common_tags
}

# DNS Records - MX Records
resource "azurerm_dns_mx_record" "mx_records" {
  for_each = { for record in var.mx_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = each.value.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }

  tags = local.common_tags
}

# DNS Records - TXT Records
resource "azurerm_dns_txt_record" "txt_records" {
  for_each = { for record in var.txt_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value
    }
  }

  tags = local.common_tags
}

# DNS Records - SRV Records
resource "azurerm_dns_srv_record" "srv_records" {
  for_each = { for record in var.srv_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = each.value.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }

  tags = local.common_tags
}

# DNS Records - PTR Records
resource "azurerm_dns_ptr_record" "ptr_records" {
  for_each = { for record in var.ptr_records : record.name => record }

  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = local.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl
  records             = each.value.records

  tags = local.common_tags
}

# Private DNS Zone Link (if specified)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  count = var.virtual_network_id != null ? 1 : 0

  name                  = "${local.dns_zone_name}-vnet-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_dns_zone.main.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.enable_auto_registration

  tags = local.common_tags
}

# DNS Zone monitoring and alerting
resource "azurerm_monitor_metric_alert" "dns_query_volume" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${local.dns_zone_name}-query-volume-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_dns_zone.main.id]

  description = "Alert when DNS query volume exceeds threshold"
  frequency   = "PT5M"
  window_size = "PT15M"
  severity    = 2

  criteria {
    metric_namespace = "Microsoft.Network/dnszones"
    metric_name      = "QueryVolume"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.query_volume_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}

# DNS Zone record set count monitoring
resource "azurerm_monitor_metric_alert" "dns_record_set_count" {
  count               = var.enable_monitoring && var.record_set_count_threshold > 0 ? 1 : 0
  name                = "${local.dns_zone_name}-record-count-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_dns_zone.main.id]

  description = "Alert when DNS record set count exceeds threshold"
  frequency   = "PT15M"
  window_size = "PT30M"
  severity    = 1

  criteria {
    metric_namespace = "Microsoft.Network/dnszones"
    metric_name      = "RecordSetCount"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.record_set_count_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = local.common_tags
}

# DNS Zone delegation verification
data "azurerm_dns_zone" "parent" {
  count               = var.verify_delegation && var.parent_zone_name != null ? 1 : 0
  name                = var.parent_zone_name
  resource_group_name = var.parent_zone_resource_group_name != null ? var.parent_zone_resource_group_name : local.resource_group_name
}

# Child zone NS record in parent zone (for delegation)
resource "azurerm_dns_ns_record" "delegation" {
  count = var.enable_delegation && var.parent_zone_name != null ? 1 : 0

  zone_name           = var.parent_zone_name
  resource_group_name = var.parent_zone_resource_group_name != null ? var.parent_zone_resource_group_name : local.resource_group_name
  name                = replace(local.dns_zone_name, ".${var.parent_zone_name}", "")
  ttl                 = var.delegation_ttl
  records             = azurerm_dns_zone.main.name_servers

  tags = local.common_tags

  depends_on = [azurerm_dns_zone.main]
}