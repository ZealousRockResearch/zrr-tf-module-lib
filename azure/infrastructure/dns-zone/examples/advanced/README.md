# Advanced DNS Zone Example

This example demonstrates the full capabilities of the Azure DNS Zone module with comprehensive enterprise features including all record types, delegation, monitoring, and security configurations.

## What This Example Creates

- **Complete DNS Zone**: Production-ready DNS zone with all record types
- **Comprehensive Records**: A, AAAA, CNAME, MX, TXT, SRV, PTR records
- **DNS Delegation**: Automatic delegation setup with parent zone
- **Enterprise Monitoring**: Query volume and record count alerts
- **Security Features**: DNSSEC zone signing configuration
- **Advanced SOA**: Custom Start of Authority record configuration
- **Email Security**: SPF, DKIM, DMARC records for email authentication
- **Service Discovery**: SRV records for various services
- **Reverse DNS**: PTR records for reverse lookups

## DNS Records Included

### A Records (IPv4)
- `www` - Load balanced web servers (multiple IPs)
- `api` - API server with short TTL for quick failover
- `app` - Application servers

### AAAA Records (IPv6)
- `www` - IPv6 web servers
- `api` - IPv6 API server

### CNAME Records
- `blog` - Points to www
- `docs` - Points to app server
- `ftp` - Points to file server

### MX Records (Mail Exchange)
- Primary mail server (priority 10)
- Secondary mail server (priority 20)
- Backup mail server (priority 30)

### TXT Records
- **SPF Record**: Email sender validation
- **DMARC Record**: Email authentication policy
- **DKIM Record**: Email signing key
- **Domain Verification**: Google, Microsoft verification
- **GitHub Verification**: Organization verification

### SRV Records (Service Discovery)
- **SIP Services**: VoIP configuration
- **XMPP Services**: Chat server configuration
- **CalDAV Services**: Calendar server configuration

### PTR Records (Reverse DNS)
- Reverse lookups for web and API servers

## Usage

1. **Prerequisites Setup**:
   ```bash
   # Ensure you have:
   # - Azure CLI installed and logged in
   # - Proper permissions for DNS zone management
   # - Action Group created for alerts (if monitoring enabled)
   # - Parent zone existing (if delegation enabled)
   ```

2. **Copy and Configure**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit Configuration**:
   ```hcl
   # Update with your actual values
   zone_name           = "your-domain.com"
   resource_group_name = "your-dns-rg"

   # Configure monitoring (optional)
   action_group_id = "/subscriptions/.../actionGroups/your-alerts"

   # Configure delegation (optional)
   parent_zone_name = "your-parent-domain.com"
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Examples

### Production Email Configuration
```hcl
mx_records = [
  {
    name = "@"
    ttl  = 3600
    records = [
      {
        preference = 10
        exchange   = "mail.yourdomain.com"
      }
    ]
  }
]

txt_records = [
  {
    name = "@"
    ttl  = 3600
    records = [
      "v=spf1 include:_spf.google.com ~all",
      "google-site-verification=your-verification-code"
    ]
  },
  {
    name = "_dmarc"
    ttl  = 3600
    records = [
      "v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com"
    ]
  }
]
```

### Service Discovery Configuration
```hcl
srv_records = [
  {
    name = "_sip._tcp"
    ttl  = 3600
    records = [
      {
        priority = 10
        weight   = 5
        port     = 5060
        target   = "sip.yourdomain.com"
      }
    ]
  }
]
```

### High Availability Web Setup
```hcl
a_records = [
  {
    name    = "www"
    ttl     = 300  # Short TTL for quick failover
    records = [
      "192.168.1.10",  # Primary server
      "192.168.1.11"   # Secondary server
    ]
  }
]
```

## Monitoring and Alerting

When monitoring is enabled, alerts will trigger for:

- **Query Volume**: When DNS queries exceed 10,000 per monitoring period
- **Record Count**: When record sets exceed 5,000 (approaching limits)

Configure your Action Group to receive alerts via:
- Email notifications
- SMS alerts
- Webhook integrations
- Azure Logic Apps

## Security Features

### DNSSEC Configuration
```hcl
enable_zone_signing                   = true
zone_signing_key_rollover_frequency  = 30  # days
```

### Email Security (SPF/DKIM/DMARC)
The example includes comprehensive email security records:
- SPF records prevent email spoofing
- DKIM records enable email signing
- DMARC records define authentication policy

## DNS Delegation

When delegation is enabled:
1. Child zone is created with unique name servers
2. NS records are automatically created in the parent zone
3. Delegation verification ensures parent zone exists
4. TTL is optimized for delegation scenarios

## Advanced Features

### Custom SOA Record
```hcl
soa_record = {
  email         = "admin.yourdomain.com"
  expire_time   = 2419200  # 4 weeks
  minimum_ttl   = 300      # 5 minutes
  refresh_time  = 3600     # 1 hour
  retry_time    = 300      # 5 minutes
}
```

### Virtual Network Integration
```hcl
virtual_network_id       = "/subscriptions/.../virtualNetworks/main-vnet"
enable_auto_registration = true
```

## Testing and Validation

After deployment, test your DNS configuration:

```bash
# Test basic resolution
nslookup www.yourdomain.com

# Test mail exchange
nslookup -type=MX yourdomain.com

# Test text records
nslookup -type=TXT yourdomain.com

# Test service records
nslookup -type=SRV _sip._tcp.yourdomain.com

# Test delegation
nslookup -type=NS subdomain.yourdomain.com
```

## Cost Optimization

- Use appropriate TTL values (longer TTL = fewer queries = lower cost)
- Monitor query volumes through Azure Monitor
- Consider record consolidation where possible
- Use CNAME records to reduce A record count

## Troubleshooting

Common issues and solutions:

1. **Delegation Not Working**:
   - Verify parent zone exists and is accessible
   - Check NS record creation in parent zone
   - Validate name server propagation

2. **High Query Volume**:
   - Review TTL settings (increase if appropriate)
   - Check for DNS amplification attacks
   - Validate record configurations

3. **DNSSEC Issues**:
   - Ensure Azure DNS Premium tier
   - Verify key rollover settings
   - Check DS record publication in parent zone

## Next Steps

- Configure monitoring dashboards in Azure Monitor
- Set up automated backups of DNS configuration
- Implement DNS failover strategies
- Configure geographic DNS routing (if needed)