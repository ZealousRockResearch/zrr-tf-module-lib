# Advanced Example - Azure Storage File Share

This example demonstrates the advanced features of the Azure Storage File Share module with comprehensive configuration including backup, monitoring, private networking, and enterprise features.

## Overview

This advanced example creates:
- Azure File Share with Premium access tier and 1TB quota
- Comprehensive directory structure with metadata
- Advanced backup policies with yearly retention
- Monitoring and alerting with email notifications
- Access policies for controlled access
- Optional private endpoint configuration
- Enterprise-grade tagging and compliance features

## Features Demonstrated

### 1. Advanced File Share Configuration
- Premium access tier for high performance
- Large quota allocation (1TB)
- SMB protocol with enterprise metadata
- Custom directory structure

### 2. Comprehensive Backup Strategy
- Daily backups at 2 AM
- 30-day daily retention
- 12-week weekly retention
- 12-month monthly retention
- 7-year yearly retention
- Soft delete protection
- Private backup vault access

### 3. Monitoring and Alerting
- Quota usage monitoring
- High-severity alerts at 85% usage
- Multiple email recipients
- Action group integration

### 4. Access Control
- Stored access policies with expiration
- Granular permissions (read, write, delete, list)
- Time-bound access control

### 5. Private Networking (Optional)
- Private endpoint configuration
- Private DNS integration
- Secure network isolation

## Prerequisites

Before running this example, ensure you have:

1. **Azure Storage Account** (Premium recommended for Premium access tier)
2. **Resource Group** with appropriate permissions
3. **Virtual Network and Subnet** (if using private endpoints)
4. **Private DNS Zone** (if using private endpoints)
5. **Email addresses** for alert notifications

## Usage

1. **Copy the example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configure required values in `terraform.tfvars`:**
   ```hcl
   # Required values
   storage_account_name = "your-premium-storage-account"
   resource_group_name  = "your-production-rg"

   # Alert configuration
   alert_email_addresses = ["admin@yourcompany.com", "devops@yourcompany.com"]
   ```

3. **Optional: Configure private networking:**
   ```hcl
   enable_private_endpoint     = true
   private_endpoint_subnet_id  = "/subscriptions/.../subnets/storage-subnet"
   private_dns_zone_id        = "/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"
   ```

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Details

### Directory Structure
The example creates four directories:
- `documents/` - Document storage with read-write access
- `backups/` - Backup storage with write-only access
- `shared/` - Shared storage with read-write access
- `archive/` - Archive storage with read-only access

### Backup Policy
- **Daily**: 30 days retention, 2 AM backup time
- **Weekly**: 12 weeks retention, Sunday backups
- **Monthly**: 12 months retention, first Sunday of month
- **Yearly**: 7 years retention, first Sunday of January

### Monitoring Alerts
- **Quota Alert**: Triggers at 85% usage
- **Severity**: High (level 1)
- **Recipients**: Multiple email addresses
- **Action**: Email notifications via action group

### Tags Applied
The example applies comprehensive tagging:
- Environment classification
- Project and ownership information
- Cost center tracking
- Compliance requirements
- Technical specifications

## Expected Outputs

After successful deployment, you'll receive:

```bash
# File Share Information
file_share_id                  = "Azure resource ID"
file_share_name               = "production-file-share"
file_share_url               = "https://storage.file.core.windows.net/share"
file_share_quota_gb          = 1000
file_share_access_tier       = "Premium"

# Directory Structure
directories = {
  "documents" = { id = "...", name = "documents", metadata = {...} }
  "backups"   = { id = "...", name = "backups", metadata = {...} }
  # ... etc
}

# Backup Resources
backup_vault_id              = "Backup vault resource ID"
backup_vault_name            = "production-backup-vault"
backup_policy_id             = "Backup policy resource ID"

# Monitoring Resources
action_group_id              = "Action group resource ID"
quota_alert_id               = "Metric alert resource ID"

# Private Networking (if enabled)
private_endpoint_id          = "Private endpoint resource ID"
private_endpoint_ip_addresses = "10.0.1.4"
```

## Testing the Deployment

### 1. Verify File Share Access
```bash
# Mount the file share (Linux/Mac)
sudo mkdir /mnt/fileshare
sudo mount -t cifs //storageaccount.file.core.windows.net/production-file-share /mnt/fileshare -o username=storageaccount,password=accountkey

# Windows
net use Z: \\storageaccount.file.core.windows.net\production-file-share /user:storageaccount accountkey
```

### 2. Test Directory Structure
```bash
# List directories
ls /mnt/fileshare/
# Should show: documents/ backups/ shared/ archive/
```

### 3. Verify Backup Configuration
- Check Azure portal for backup vault
- Verify backup policy settings
- Confirm protection status

### 4. Test Monitoring
- Simulate quota usage approaching 85%
- Verify alert emails are received
- Check action group functionality

## Cost Considerations

This advanced example includes several billable components:

1. **File Share**: Premium tier storage costs
2. **Backup Vault**: Backup storage and operations
3. **Monitoring**: Metric alerts and action groups
4. **Private Endpoint**: Network resources (if enabled)

Estimated monthly cost for 1TB Premium file share: $150-200 USD

## Security Features

### Access Control
- Time-bound access policies
- Granular permissions
- Stored access policies with expiration

### Network Security
- Private endpoint isolation
- Private DNS resolution
- Network access restrictions

### Data Protection
- Comprehensive backup with long-term retention
- Soft delete protection
- Metadata encryption

### Compliance
- Comprehensive audit trail
- Enterprise tagging
- Retention policy compliance

## Troubleshooting

### Common Issues

1. **Storage Account Compatibility**
   - Premium access tier requires Premium storage accounts
   - Verify account supports file shares

2. **Private Endpoint Issues**
   - Ensure subnet allows private endpoints
   - Verify DNS zone configuration
   - Check network security group rules

3. **Backup Configuration**
   - Verify Recovery Services Vault permissions
   - Check backup policy compatibility
   - Ensure storage account registration

4. **Monitoring Alerts**
   - Verify email addresses are correct
   - Check action group configuration
   - Test metric alert conditions

### Support Resources

- [Azure Files Documentation](https://docs.microsoft.com/en-us/azure/storage/files/)
- [Azure Backup for File Shares](https://docs.microsoft.com/en-us/azure/backup/azure-file-share-backup-overview)
- [Private Endpoints for Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)

## Clean Up

To remove all resources:

```bash
terraform destroy
```

**Note**: Backup data may be retained based on retention policies even after destroying the infrastructure.

## Next Steps

After deploying this advanced example:

1. **Configure Clients**: Set up file share mounts on client systems
2. **Test Backup/Restore**: Perform backup and restore testing
3. **Monitor Usage**: Review quota and performance metrics
4. **Security Audit**: Validate access controls and network security
5. **Compliance Review**: Ensure tagging and retention meet requirements