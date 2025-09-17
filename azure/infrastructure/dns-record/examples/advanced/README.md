# Advanced DNS Record Example

This example demonstrates enterprise-grade DNS record management with comprehensive monitoring, compliance, security features, and advanced record types.

## What This Example Creates

- Advanced DNS records with enterprise governance
- Comprehensive monitoring and alerting
- Security controls and access restrictions
- Compliance tracking and audit logging
- Health checks and automated failover
- Lifecycle management with approval workflows
- Support for complex record types (MX, SRV)

## Enterprise Features

### 🔍 Monitoring & Observability
- Real-time DNS record monitoring
- Health checks with automatic failover
- Performance metrics and SLA tracking
- Custom alerting rules and notifications

### 🔒 Security & Compliance
- Access restrictions and change protection
- Comprehensive audit logging
- Encryption in transit
- Multi-compliance framework support (SOX, PCI-DSS, ISO27001, GDPR, HIPAA)

### 🔄 Lifecycle Management
- Change approval workflows
- Automated backup and recovery
- Scheduled maintenance windows
- Record validation and format checking

### 📊 Advanced Record Types
- **MX Records**: Mail exchange configuration
- **SRV Records**: Service discovery and load balancing
- **Multi-value Records**: High availability configurations
- **Weighted Routing**: Traffic distribution control

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Configure your enterprise settings:
   ```bash
   # Edit terraform.tfvars with your specific values
   vim terraform.tfvars
   ```

3. Review and customize security policies:
   - Update access restrictions
   - Configure compliance requirements
   - Set monitoring thresholds
   - Define approval workflows

4. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Examples

### High-Availability API Endpoint
```hcl
record_name = "api-ha"
record_type = "A"
records     = ["203.0.113.10", "203.0.113.11", "203.0.113.12"]
ttl         = 300

enable_monitoring = true
health_check_enabled = true
alert_on_changes = true

security_config = {
  access_restrictions   = ["10.0.0.0/8"]
  change_protection    = true
  audit_logging       = true
  encryption_in_transit = true
}
```

### Mail Exchange Records
```hcl
record_name = "mail"
record_type = "MX"
mx_records = [
  {
    preference = 10
    exchange   = "mail1.company.com."
  },
  {
    preference = 20
    exchange   = "mail2.company.com."
  }
]
```

### Service Discovery (SRV)
```hcl
record_name = "_sip._tcp"
record_type = "SRV"
srv_records = [
  {
    priority = 10
    weight   = 60
    port     = 5060
    target   = "sip1.company.com."
  }
]
```

### Private DNS Zone Configuration
```hcl
private_dns_zone_name               = "internal.company.local"
private_dns_zone_resource_group_name = "private-dns-rg"

# Enhanced security for internal services
security_config = {
  access_restrictions   = ["10.0.0.0/8", "172.16.0.0/12"]
  change_protection    = true
  audit_logging       = true
  encryption_in_transit = true
}
```

## Advanced Configuration

### Compliance & Governance
Configure multiple compliance frameworks:
```hcl
compliance_requirements = [
  "SOX",     # Sarbanes-Oxley
  "PCI-DSS", # Payment Card Industry
  "ISO27001", # Information Security
  "GDPR",    # General Data Protection Regulation
  "HIPAA"    # Health Insurance Portability
]
```

### Record Lifecycle Management
```hcl
record_lifecycle = {
  auto_delete_after_days    = null  # Never auto-delete
  backup_enabled           = true
  change_approval_required = true
  scheduled_updates        = false
}
```

### Validation Rules
```hcl
validation_rules = {
  strict_format_checking = true
  allow_wildcard_records = false
  max_record_count      = 10
  forbidden_values      = ["127.0.0.1", "localhost"]
}
```

## Monitoring & Alerting

The advanced example includes comprehensive monitoring:

- **DNS Resolution Monitoring**: Continuous validation of record resolution
- **Health Checks**: Endpoint availability monitoring
- **Performance Metrics**: Response time and availability SLAs
- **Change Alerts**: Notifications for any record modifications
- **Compliance Reporting**: Automated compliance status tracking

## Security Features

### Access Controls
- IP-based access restrictions
- Change protection mechanisms
- Audit logging for all operations
- Encryption in transit

### Compliance Tracking
- Multi-framework support
- Automated compliance validation
- Audit trail maintenance
- Regular compliance reporting

## Best Practices

1. **Production Readiness**
   - Use lower TTL values for critical services (300s or less)
   - Enable monitoring and health checks
   - Configure appropriate backup and recovery

2. **Security Hardening**
   - Restrict access to trusted networks only
   - Enable change protection for critical records
   - Maintain comprehensive audit logs

3. **Operational Excellence**
   - Implement change approval workflows
   - Use enterprise tagging standards
   - Configure automated monitoring and alerting

4. **Compliance Management**
   - Define applicable compliance requirements
   - Regular compliance status reviews
   - Maintain proper documentation

## Clean Up

To remove the DNS record and all associated monitoring:
```bash
terraform destroy
```

**Warning**: This will remove all DNS records, monitoring configurations, and compliance tracking. Ensure this won't disrupt production services.

## Troubleshooting

### Common Issues

1. **Access Denied**: Check security_config.access_restrictions
2. **Health Check Failures**: Verify endpoint availability and firewall rules
3. **Compliance Violations**: Review compliance_requirements and validation_rules
4. **Change Rejection**: Ensure proper approval workflow completion

### Monitoring Dashboard

Access your enterprise monitoring dashboard to view:
- Real-time DNS resolution metrics
- Health check status and history
- Compliance posture and violations
- Change audit trail and approvals

For additional support, contact the Platform Engineering team.