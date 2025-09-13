# Advanced Key Vault Example

This example demonstrates a production-ready Azure Key Vault configuration with comprehensive security features, private networking, monitoring, and enterprise-grade access controls.

## Features Demonstrated

- **Premium SKU**: HSM-backed keys for maximum security
- **Private Networking**: Private endpoint with DNS integration
- **Network Security**: Restricted access with IP and subnet allowlists
- **Access Policies**: Granular permissions for different roles
- **Secrets Management**: Production secrets with metadata and expiration
- **Key Management**: HSM-backed encryption and signing keys
- **Monitoring**: Comprehensive diagnostic settings
- **Compliance**: Enterprise tagging and security controls

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Environment                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   Applications  │    │  Backup Service │                │
│  │                 │    │                 │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                        │
│  ┌─────────────────────────────────────────────┐          │
│  │            Network ACLs                     │          │
│  │  - Deny by default                          │          │
│  │  - Allow corporate IP ranges                │          │
│  │  - Allow application subnets                │          │
│  └─────────────────────────────────────────────┘          │
│           │                                                │
│  ┌─────────────────────────────────────────────┐          │
│  │         Private Endpoint                    │          │
│  │  - Private subnet access only               │          │
│  │  - DNS integration                          │          │
│  └─────────────────────────────────────────────┘          │
│           │                                                │
│  ┌─────────────────────────────────────────────┐          │
│  │            Key Vault Premium                │          │
│  │  - HSM-backed keys                          │          │
│  │  - Application secrets                      │          │
│  │  - Encryption keys                          │          │
│  │  - Signing keys                             │          │
│  └─────────────────────────────────────────────┘          │
│           │                                                │
│  ┌─────────────────────────────────────────────┐          │
│  │         Monitoring & Logging                │          │
│  │  - Log Analytics Workspace                  │          │
│  │  - Storage Account (long-term)              │          │
│  │  - Audit events & metrics                   │          │
│  └─────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

Before deploying this example, ensure you have:

1. **Existing Infrastructure**:
   - Virtual network with private endpoint subnet
   - Private DNS zone for Key Vault
   - Log Analytics workspace
   - Storage account for diagnostic logs

2. **Azure AD Objects**:
   - Service principal for applications
   - Service principal for backup services
   - Proper RBAC assignments

3. **Network Configuration**:
   - Subnet allow list configured
   - IP allow list for management access
   - Private DNS zone linked to VNet

## Usage

1. **Prepare Configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update Variables**:
   - Replace example Object IDs with real service principals
   - Update network configuration for your environment
   - Configure proper contact information
   - **IMPORTANT**: Handle secrets securely (use Azure DevOps variable groups)

3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Features

### Access Control
- **Role-based Access**: Different permissions for admin, application, and backup roles
- **Principle of Least Privilege**: Minimal required permissions per role
- **Time-limited Access**: Secrets with expiration dates

### Network Security
- **Private Endpoint**: No public internet access
- **Network ACLs**: IP and subnet-based restrictions
- **DNS Integration**: Private DNS resolution

### Key Management
- **HSM-backed Keys**: Premium SKU provides hardware security modules
- **Key Rotation**: Metadata tracking for rotation schedules
- **Purpose-specific Keys**: Different keys for different use cases

### Monitoring
- **Audit Logging**: All access attempts logged
- **Metrics Collection**: Performance and usage metrics
- **Long-term Storage**: Audit logs retained in storage account

## Production Considerations

### Secrets Management
```bash
# Use Azure DevOps variable groups instead of plain text
# Example pipeline variable configuration:
variables:
  - group: 'keyvault-secrets-prod'
  - name: 'database_connection'
    value: $(DATABASE_CONNECTION_STRING)
```

### Key Rotation
```bash
# Implement automated key rotation
# Example: Set up Azure Automation runbooks
```

### Monitoring Alerts
```bash
# Set up alerts for:
# - Unauthorized access attempts
# - Key usage anomalies
# - Certificate expiration warnings
```

### Backup Strategy
```bash
# Configure backup policies:
# - Regular secret backups
# - Key export procedures
# - Disaster recovery procedures
```

## Compliance Features

This configuration includes features for common compliance frameworks:

- **SOC 2**: Audit logging, access controls, monitoring
- **PCI DSS**: Network restrictions, encryption, key management
- **ISO 27001**: Security controls, documentation, monitoring

## Cost Optimization

- **Premium SKU**: Only used when HSM-backed keys are required
- **Diagnostic Settings**: Configured for both real-time and long-term storage
- **Resource Tagging**: Comprehensive cost allocation tags

## Customization Options

### Network Security
```hcl
# Adjust for your network topology
allowed_ip_ranges = ["your.corporate.network/24"]
allowed_subnet_ids = ["/subscriptions/.../subnets/your-app-subnet"]
```

### Access Policies
```hcl
# Add additional roles as needed
access_policies = {
  readonly_users = {
    object_id = "..."
    key_permissions = ["Get"]
    secret_permissions = ["Get"]
    certificate_permissions = ["Get"]
  }
}
```

### Keys and Secrets
```hcl
# Customize based on your application needs
keys = {
  your_encryption_key = {
    key_type = "RSA-HSM"
    key_size = 4096
    key_opts = ["encrypt", "decrypt"]
  }
}
```

## Troubleshooting

### Common Issues

1. **Private Endpoint Connectivity**:
   - Verify subnet configuration
   - Check DNS resolution
   - Validate NSG rules

2. **Access Policy Issues**:
   - Verify Object IDs are correct
   - Check Azure AD permissions
   - Validate RBAC assignments

3. **Network ACL Problems**:
   - Verify IP range formats
   - Check subnet ID syntax
   - Validate VNet configuration

### Debugging Commands

```bash
# Test private endpoint connectivity
nslookup your-keyvault.vault.azure.net

# Verify access policies
az keyvault show --name your-keyvault --query properties.accessPolicies

# Check diagnostic settings
az monitor diagnostic-settings list --resource /subscriptions/.../providers/Microsoft.KeyVault/vaults/your-keyvault
```