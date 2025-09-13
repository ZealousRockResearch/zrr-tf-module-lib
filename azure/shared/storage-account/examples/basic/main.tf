# Basic Azure Storage Account Example
# This example demonstrates a simple storage account configuration suitable for development and testing

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-basic-example"
  location = "East US"

  tags = {
    Environment = "dev"
    Project     = "zrr-terraform-modules"
    Purpose     = "basic-storage-example"
  }
}

# Basic Storage Account Configuration
module "storage_account" {
  source = "../../"

  # Required variables
  name                = "basicstorageexample"
  resource_group_name = azurerm_resource_group.example.name
  environment         = "dev"

  # Basic storage configuration
  account_tier     = "Standard"
  replication_type = "LRS"
  account_kind     = "StorageV2"
  access_tier      = "Hot"

  # Security settings (recommended defaults)
  enable_https_traffic_only    = true
  min_tls_version              = "TLS1_2"
  allow_public_access          = false
  enable_shared_access_key     = true
  enable_public_network_access = true

  # Enable basic blob properties
  enable_blob_properties          = true
  blob_delete_retention_days      = 7
  container_delete_retention_days = 7

  # Create basic storage containers
  containers = [
    {
      name        = "documents"
      access_type = "private"
      metadata = {
        purpose = "document-storage"
      }
    },
    {
      name        = "images"
      access_type = "private"
      metadata = {
        purpose = "image-storage"
      }
    },
    {
      name        = "backups"
      access_type = "private"
      metadata = {
        purpose = "backup-storage"
      }
    }
  ]

  # Create basic file shares
  file_shares = [
    {
      name        = "shared-files"
      quota_gb    = 100
      access_tier = "TransactionOptimized"
      protocol    = "SMB"
      metadata = {
        purpose = "shared-file-storage"
      }
    }
  ]

  # Create basic queues
  queues = [
    {
      name = "processing-queue"
      metadata = {
        purpose = "message-processing"
      }
    }
  ]

  # Naming convention
  use_naming_convention = true
  location_short        = "eus"

  # Tagging
  common_tags = {
    Environment = "dev"
    Project     = "zrr-terraform-modules"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }

  storage_account_tags = {
    Purpose = "basic-storage-example"
    Tier    = "development"
  }
}

# Output the storage account details
output "storage_account_name" {
  description = "The name of the created storage account"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "The ID of the created storage account"
  value       = module.storage_account.storage_account_id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = module.storage_account.primary_file_endpoint
}

output "containers" {
  description = "Created storage containers"
  value       = module.storage_account.containers
}

output "file_shares" {
  description = "Created file shares"
  value       = module.storage_account.file_shares
}

output "queues" {
  description = "Created storage queues"
  value       = module.storage_account.queues
}