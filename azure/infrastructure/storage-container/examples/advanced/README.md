# Advanced Example - Azure Storage Container

This example demonstrates enterprise-grade usage of the Azure Storage Container module with advanced features including lifecycle management, legal hold, immutability policies, and multi-container orchestration.

## Features Demonstrated

### 1. Compliance Container
- **Legal Hold**: Litigation and regulatory compliance capabilities
- **Immutability Policy**: WORM (Write Once, Read Many) for regulatory requirements
- **Advanced Lifecycle Rules**: Multi-tier storage optimization with retention policies
- **Compliance Metadata**: Enhanced metadata for governance and auditing

### 2. Application Data Container
- **Dynamic Configuration**: Environment-based naming and configuration
- **Application-Specific Lifecycle**: Optimized for application data patterns
- **Flexible Access Control**: Configurable access types based on use case

### 3. Backup Container
- **Backup-Optimized Lifecycle**: Immediate cool storage with long-term archive
- **Multi-Tier Retention**: Different policies for daily, weekly, monthly, and annual backups
- **Operational Metadata**: Enhanced tracking for backup operations

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Configure your specific values in `terraform.tfvars`:
   - Storage account details
   - Environment settings
   - Compliance requirements (legal hold, immutability)
   - Lifecycle management preferences

3. Review and customize the configuration:
   ```bash
   # Review the planned changes
   terraform init
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Examples

### Production Environment with Full Compliance
```hcl
environment = "prod"
enable_legal_hold = true
enable_immutability_policy = true
immutability_period_days = 2555  # 7 years
immutability_policy_locked = true
```

### Development Environment with Relaxed Policies
```hcl
environment = "dev"
enable_legal_hold = false
enable_immutability_policy = false
enable_app_lifecycle = true
```

### Staging Environment for Testing
```hcl
environment = "stage"
enable_legal_hold = false
enable_immutability_policy = true
immutability_period_days = 365  # 1 year for testing
immutability_policy_locked = false
```

## Lifecycle Management

This example includes comprehensive lifecycle rules:

- **Documents/Records**: 30 days → Cool, 90 days → Archive, 7 years → Delete
- **Logs**: 7 days → Cool, 30 days → Archive, 1 year → Delete
- **Temporary Files**: 30 days → Delete
- **Application Data**: 60 days → Cool, 180 days → Archive, 3 years → Delete
- **Daily Backups**: Immediate Cool, 30 days → Archive, 3 years → Delete
- **Annual Backups**: Immediate Archive, 10 years → Delete

## Security Features

- **Private Access**: All containers default to private access
- **Legal Hold**: Configurable litigation hold with multiple tags
- **Immutability**: Time-based retention with lockable policies
- **Metadata**: Comprehensive metadata for governance and compliance
- **Enterprise Tagging**: Full ZRR tagging standards implementation

## Prerequisites

- Azure Storage Account with appropriate SKU for advanced features
- Sufficient permissions for lifecycle management and legal hold operations
- Understanding of regulatory requirements for immutability policies

## Important Notes

⚠️ **Immutability Policy Warning**: Once locked, immutability policies cannot be modified or deleted until the retention period expires.

⚠️ **Legal Hold Impact**: Legal holds prevent deletion of blobs regardless of lifecycle policies.

⚠️ **Cost Implications**: Advanced storage tiers and long retention periods have associated costs.

## Outputs

This example provides comprehensive outputs including:
- Individual container details and URLs
- Security feature status for each container
- Lifecycle rule counts and management policy IDs
- Summary view of all containers and their configurations