module "key_vault_secret_example" {
  source = "../../"

  name                          = "example-secret"
  value                         = var.secret_value
  key_vault_name                = var.key_vault_name
  key_vault_resource_group_name = var.key_vault_resource_group_name

  content_type    = "text/plain"
  expiration_date = "2025-12-31T23:59:59Z"

  common_tags = var.common_tags

  key_vault_secret_tags = {
    Purpose = "example"
    Type    = "demo"
  }
}