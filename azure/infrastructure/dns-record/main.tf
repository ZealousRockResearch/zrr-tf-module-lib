# azure-infrastructure-dns-record module
# Description: Manages Azure DNS Records with comprehensive record type support, validation, monitoring, and enterprise governance capabilities

terraform {
  required_version = ">= 1.0"
}

# Data sources
data "azurerm_dns_zone" "main" {
  count               = var.dns_zone_name != null ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "main" {
  count               = var.private_dns_zone_name != null ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = merge(
    var.common_tags,
    var.dns_record_tags,
    {
      "ManagedBy" = "Terraform"
      "Module"    = "zrr-tf-module-lib/azure/infrastructure/dns-record"
      "Layer"     = "infrastructure"
    }
  )

  # Determine DNS zone based on zone type
  dns_zone_name = var.dns_zone_id != null ? split("/", var.dns_zone_id)[8] : (
    var.dns_zone_name != null ? var.dns_zone_name : var.private_dns_zone_name
  )

  # Determine resource group based on zone type
  dns_zone_resource_group = var.dns_zone_id != null ? split("/", var.dns_zone_id)[4] : (
    var.dns_zone_resource_group_name != null ? var.dns_zone_resource_group_name : var.private_dns_zone_resource_group_name
  )

  # Validate that exactly one DNS zone reference is provided
  zone_reference_count = length([
    for ref in [var.dns_zone_id, var.dns_zone_name, var.private_dns_zone_name] : ref
    if ref != null
  ])

  # Determine if this is a private DNS zone
  is_private_zone = var.private_dns_zone_name != null || can(regex("privateDnsZones", var.dns_zone_id))

  # Record validation
  record_type_upper = upper(var.record_type)

  # TTL validation
  ttl_value = var.ttl != null ? var.ttl : var.default_ttl

  # Record value validation based on type
  record_values_valid = alltrue([
    for record in var.records : can(regex(
      local.record_type_upper == "A" ? "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$" :
      local.record_type_upper == "AAAA" ? "^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$" :
      local.record_type_upper == "CNAME" ? "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$" :
      local.record_type_upper == "MX" ? "^[0-9]+ [a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$" :
      local.record_type_upper == "TXT" ? ".*" :
      local.record_type_upper == "NS" ? "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$" :
      local.record_type_upper == "SRV" ? "^[0-9]+ [0-9]+ [0-9]+ [a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*\\.$" :
      ".*", record
    ))
  ])

  # FQDN construction
  record_fqdn = var.name == "@" ? local.dns_zone_name : "${var.name}.${local.dns_zone_name}"
}

# Validation checks
resource "null_resource" "validation" {
  lifecycle {
    precondition {
      condition     = local.zone_reference_count == 1
      error_message = "Exactly one DNS zone reference must be provided: dns_zone_id, dns_zone_name, or private_dns_zone_name."
    }

    precondition {
      condition     = local.record_values_valid
      error_message = "All record values must be valid for the specified record type."
    }

    precondition {
      condition     = var.dns_zone_name == null || var.dns_zone_resource_group_name != null
      error_message = "dns_zone_resource_group_name is required when dns_zone_name is provided."
    }

    precondition {
      condition     = var.private_dns_zone_name == null || var.private_dns_zone_resource_group_name != null
      error_message = "private_dns_zone_resource_group_name is required when private_dns_zone_name is provided."
    }

    precondition {
      condition     = contains(["A", "AAAA", "CNAME", "MX", "NS", "PTR", "SOA", "SRV", "TXT", "CAA"], local.record_type_upper)
      error_message = "Record type must be one of: A, AAAA, CNAME, MX, NS, PTR, SOA, SRV, TXT, CAA."
    }

    precondition {
      condition     = local.record_type_upper != "CNAME" || length(var.records) == 1
      error_message = "CNAME records must have exactly one record value."
    }

    precondition {
      condition     = local.ttl_value >= 1 && local.ttl_value <= 2147483647
      error_message = "TTL must be between 1 and 2147483647 seconds."
    }
  }
}

# Public DNS Zone Records
resource "azurerm_dns_a_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "A" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  records             = var.records
  tags                = local.common_tags
}

resource "azurerm_dns_aaaa_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "AAAA" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  records             = var.records
  tags                = local.common_tags
}

resource "azurerm_dns_cname_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "CNAME" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  record              = var.records[0]
  tags                = local.common_tags
}

resource "azurerm_dns_mx_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "MX" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.mx_records != null ? var.mx_records : []
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_dns_ns_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "NS" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  records             = var.records
  tags                = local.common_tags
}

resource "azurerm_dns_txt_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "TXT" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.records
    content {
      value = record.value
    }
  }
}

resource "azurerm_dns_srv_record" "main" {
  count = !local.is_private_zone && local.record_type_upper == "SRV" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.srv_records != null ? var.srv_records : []
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}

# Private DNS Zone Records
resource "azurerm_private_dns_a_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "A" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  records             = var.records
  tags                = local.common_tags
}

resource "azurerm_private_dns_aaaa_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "AAAA" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  records             = var.records
  tags                = local.common_tags
}

resource "azurerm_private_dns_cname_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "CNAME" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  record              = var.records[0]
  tags                = local.common_tags
}

resource "azurerm_private_dns_mx_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "MX" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.mx_records != null ? var.mx_records : []
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_private_dns_txt_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "TXT" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.records
    content {
      value = record.value
    }
  }
}

resource "azurerm_private_dns_srv_record" "main" {
  count = local.is_private_zone && local.record_type_upper == "SRV" ? 1 : 0

  name                = var.name
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group
  ttl                 = local.ttl_value
  tags                = local.common_tags

  dynamic "record" {
    for_each = var.srv_records != null ? var.srv_records : []
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}