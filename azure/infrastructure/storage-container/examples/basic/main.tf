module "storage_container_example" {
  source = "../../"

  name                                = "example-container"
  storage_account_name                = var.storage_account_name
  storage_account_resource_group_name = var.storage_account_resource_group_name
  container_access_type               = "private"

  metadata = {
    environment = "development"
    project     = "example"
    owner       = "platform-team"
    purpose     = "demo-container"
  }

  common_tags = var.common_tags

  storage_container_tags = {
    Purpose = "example"
    Type    = "demo"
  }
}