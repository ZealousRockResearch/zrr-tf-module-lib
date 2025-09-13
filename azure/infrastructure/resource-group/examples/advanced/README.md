# Advanced Resource Group Example

This example demonstrates an enterprise-grade deployment of Azure Resource Groups with production and disaster recovery configurations, including:

- Production and DR resource groups in different regions
- Resource locks to prevent accidental deletion
- Budget alerts with customizable thresholds
- Comprehensive tagging strategy for compliance and governance
- Lifecycle protection for critical resources

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Subscription                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────┐  ┌──────────────────────────┐│
│  │  Production Resource Group│  │    DR Resource Group     ││
│  │      (East US)           │  │      (West US 2)         ││
│  │                          │  │                          ││
│  │  • Resource Lock         │  │  • Resource Lock         ││
│  │  • Budget Alert ($10k)   │  │  • Budget Alert ($3k)    ││
│  │  • Enhanced Monitoring   │  │  • Replica Configuration ││
│  │  • PCI-DSS Compliance    │  │  • Standby Resources     ││
│  └──────────────────────────┘  └──────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Azure CLI authenticated (`az login`)
- Contributor or Owner role on the subscription

## Usage

1. Copy and customize the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your organization's values:
   - Update email addresses for budget alerts
   - Adjust budget amounts based on your requirements
   - Modify tags to match your compliance requirements
   - Set appropriate locations for production and DR

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration (requires approval):
   ```bash
   terraform apply
   ```

6. Verify the deployment:
   ```bash
   terraform output resource_groups_summary
   ```

## Important Notes

### Resource Protection

- Both resource groups have `prevent_destroy = true` lifecycle rule
- Resource locks are set to `CanNotDelete` level
- Deletion requires manual intervention and approval

### Budget Monitoring

- Production: $10,000/month with 80% threshold alert
- DR: $3,000/month with 90% threshold alert
- Alerts sent to multiple stakeholders

### Compliance Tags

The example includes comprehensive tagging for:
- PCI-DSS, HIPAA, and SOC2 compliance
- Data classification (Confidential)
- Audit tracking and governance
- Change management windows
- Backup and recovery policies

## Outputs

The configuration provides detailed outputs including:
- Resource group IDs and names
- Location information
- Budget configuration status
- Lock status
- Subscription details

## Clean Up

⚠️ **Warning**: These resource groups have deletion protection enabled.

To destroy the resources:

1. First, remove the resource locks via Azure Portal or CLI
2. Update the module to set `prevent_destroy = false`
3. Apply the changes: `terraform apply`
4. Then destroy: `terraform destroy`

## Security Considerations

- Resource locks prevent accidental deletion
- Budget alerts help control costs
- Comprehensive tagging enables governance
- DR configuration ensures business continuity
- Enhanced monitoring for production workloads

## Cost Optimization

- Separate budgets for production and DR
- Threshold alerts at 80% and 90%
- Multiple notification recipients
- Monthly budget cycles for better control

## Next Steps

After deploying these resource groups, you can:
1. Deploy application infrastructure within them
2. Configure Azure Policy for additional governance
3. Set up Azure Monitor for enhanced observability
4. Implement backup and disaster recovery solutions
5. Configure network security and connectivity