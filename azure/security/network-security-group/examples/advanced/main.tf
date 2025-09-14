module "advanced_network_security_group" {
  source = "../../"

  name                = "advanced-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rules = [
    {
      name                       = "allow-web-traffic"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "443"]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP and HTTPS traffic"
    },
    {
      name                       = "allow-ssh-from-mgmt"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = var.management_subnets
      destination_address_prefix = "*"
      description                = "Allow SSH from management subnets only"
    },
    {
      name                       = "allow-database-from-app"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["3306", "5432", "1433"]
      source_address_prefixes    = var.application_subnets
      destination_address_prefix = "*"
      description                = "Allow database traffic from application subnets"
    },
    {
      name                       = "deny-internet-outbound"
      priority                   = 3000
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      description                = "Deny all outbound internet traffic"
    },
    {
      name                       = "allow-vnet-outbound"
      priority                   = 2000
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow all VNet outbound traffic"
    },
    {
      name                       = "deny-all-inbound"
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    }
  ]

  # Advanced features
  enable_flow_logs            = var.enable_flow_logs
  flow_log_storage_account_id = var.flow_log_storage_account_id
  flow_log_retention_days     = var.flow_log_retention_days
  flow_log_format_type        = "JSON"
  flow_log_format_version     = 2

  # Associations
  subnet_id             = var.subnet_id
  network_interface_ids = var.network_interface_ids

  # Tags
  common_tags = var.common_tags
  network_security_group_tags = {
    Purpose    = "advanced-security"
    Backup     = "daily"
    Monitoring = "enabled"
    Compliance = "required"
  }
}