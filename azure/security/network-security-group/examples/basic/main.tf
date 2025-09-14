module "network_security_group_example" {
  source = "../../"

  name                = "example-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rules = [
    {
      name                       = "allow-ssh"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH access"
    },
    {
      name                       = "allow-http"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP access"
    }
  ]

  common_tags = var.common_tags
}