terraform {
  backend "azurerm" {
    resource_group_name  = "rg-zrr-tfstate-dev"
    storage_account_name = "sazrrtfstatedev"
    container_name       = "tfstate"
    key                  = "resource-group/advanced/terraform.tfstate"
  }
}