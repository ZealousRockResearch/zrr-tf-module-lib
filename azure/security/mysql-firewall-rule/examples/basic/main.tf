module "mysql_firewall_rules" {
  source = "../../"

  mysql_server_name                = var.mysql_server_name
  mysql_server_resource_group_name = var.mysql_server_resource_group_name

  firewall_rules = var.firewall_rules

  allow_azure_services = var.allow_azure_services

  common_tags = var.common_tags
}