# azure-shared-storage-account module outputs
# Description: Output values for the Azure Storage Account module

# Storage Account outputs
output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.main.primary_location
}

output "storage_account_secondary_location" {
  description = "The secondary location of the storage account"
  value       = azurerm_storage_account.main.secondary_location
}

output "storage_account_kind" {
  description = "The kind of the storage account"
  value       = azurerm_storage_account.main.account_kind
}

output "storage_account_tier" {
  description = "The tier of the storage account"
  value       = azurerm_storage_account.main.account_tier
}

output "storage_account_replication_type" {
  description = "The replication type of the storage account"
  value       = azurerm_storage_account.main.account_replication_type
}

# Connection strings and keys
output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.main.secondary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

# Blob service outputs
output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location"
  value       = azurerm_storage_account.main.primary_blob_host
}

output "secondary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_blob_host
}

output "primary_blob_connection_string" {
  description = "The connection string associated with the primary blob location"
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The connection string associated with the secondary blob location"
  value       = azurerm_storage_account.main.secondary_blob_connection_string
  sensitive   = true
}

# Queue service outputs
output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_queue_endpoint
}

output "primary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the primary location"
  value       = azurerm_storage_account.main.primary_queue_host
}

output "secondary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_queue_host
}

# Table service outputs
output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_table_endpoint
}

output "primary_table_host" {
  description = "The hostname with port if applicable for table storage in the primary location"
  value       = azurerm_storage_account.main.primary_table_host
}

output "secondary_table_host" {
  description = "The hostname with port if applicable for table storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_table_host
}

# File service outputs
output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_file_endpoint
}

output "primary_file_host" {
  description = "The hostname with port if applicable for file storage in the primary location"
  value       = azurerm_storage_account.main.primary_file_host
}

output "secondary_file_host" {
  description = "The hostname with port if applicable for file storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_file_host
}

# DFS service outputs (Data Lake Storage Gen2)
output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location"
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the primary location"
  value       = azurerm_storage_account.main.primary_dfs_host
}

output "secondary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_dfs_host
}

# Web service outputs
output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location"
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_web_endpoint
}

output "primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location"
  value       = azurerm_storage_account.main.primary_web_host
}

output "secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location"
  value       = azurerm_storage_account.main.secondary_web_host
}

# Identity outputs
output "identity" {
  description = "The managed identity of the storage account"
  value = var.identity_type != "" ? {
    type         = azurerm_storage_account.main.identity[0].type
    principal_id = azurerm_storage_account.main.identity[0].principal_id
    tenant_id    = azurerm_storage_account.main.identity[0].tenant_id
    identity_ids = azurerm_storage_account.main.identity[0].identity_ids
  } : null
}

# Container outputs
output "containers" {
  description = "Map of created storage containers"
  value = {
    for k, v in azurerm_storage_container.main : k => {
      id                      = v.id
      name                    = v.name
      container_access_type   = v.container_access_type
      has_immutability_policy = v.has_immutability_policy
      has_legal_hold          = v.has_legal_hold
      resource_manager_id     = v.resource_manager_id
      metadata                = v.metadata
    }
  }
}

# File share outputs
output "file_shares" {
  description = "Map of created file shares"
  value = {
    for k, v in azurerm_storage_share.main : k => {
      id                  = v.id
      name                = v.name
      quota               = v.quota
      enabled_protocol    = v.enabled_protocol
      access_tier         = v.access_tier
      url                 = v.url
      resource_manager_id = v.resource_manager_id
      metadata            = v.metadata
    }
  }
}

# Queue outputs
output "queues" {
  description = "Map of created storage queues"
  value = {
    for k, v in azurerm_storage_queue.main : k => {
      id                  = v.id
      name                = v.name
      resource_manager_id = v.resource_manager_id
      metadata            = v.metadata
    }
  }
}

# Table outputs
output "tables" {
  description = "Map of created storage tables"
  value = {
    for k, v in azurerm_storage_table.main : k => {
      id   = v.id
      name = v.name
    }
  }
}

# Private endpoint outputs
output "private_endpoint_blob" {
  description = "Blob private endpoint details"
  value = var.enable_private_endpoints && contains(var.private_endpoint_subresource_names, "blob") ? {
    id                            = azurerm_private_endpoint.blob[0].id
    name                          = azurerm_private_endpoint.blob[0].name
    private_service_connection_id = azurerm_private_endpoint.blob[0].private_service_connection[0].private_connection_resource_id
    private_ip_address            = azurerm_private_endpoint.blob[0].private_service_connection[0].private_ip_address
    network_interface_ids         = azurerm_private_endpoint.blob[0].network_interface[0].id
  } : null
}

output "private_endpoint_file" {
  description = "File private endpoint details"
  value = var.enable_private_endpoints && contains(var.private_endpoint_subresource_names, "file") ? {
    id                            = azurerm_private_endpoint.file[0].id
    name                          = azurerm_private_endpoint.file[0].name
    private_service_connection_id = azurerm_private_endpoint.file[0].private_service_connection[0].private_connection_resource_id
    private_ip_address            = azurerm_private_endpoint.file[0].private_service_connection[0].private_ip_address
    network_interface_ids         = azurerm_private_endpoint.file[0].network_interface[0].id
  } : null
}

# Network rules output
output "network_rules" {
  description = "Network rules configuration"
  value = var.enable_network_rules ? {
    default_action             = var.network_default_action
    bypass                     = var.network_bypass
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  } : null
}

# Static website output
output "static_website" {
  description = "Static website configuration"
  value = var.enable_static_website ? {
    index_document     = var.static_website_index_document
    error_404_document = var.static_website_error_document
  } : null
}

# Lifecycle management output
output "lifecycle_management_policy_id" {
  description = "The ID of the lifecycle management policy"
  value       = var.enable_lifecycle_management ? azurerm_storage_management_policy.main[0].id : null
}

# Computed values
output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "location" {
  description = "The location of the storage account"
  value       = data.azurerm_resource_group.main.location
}

output "tags" {
  description = "The tags applied to the storage account"
  value       = azurerm_storage_account.main.tags
}