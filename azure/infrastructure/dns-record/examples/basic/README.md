# Basic DNS Record Example

This example demonstrates basic usage of the DNS Record module for simple DNS record management scenarios.

## What This Example Creates

- Basic DNS records (A, CNAME, TXT, etc.)
- Standard TTL configuration
- Basic enterprise tagging

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - DNS zone name and resource group
   - Record name, type, and values
   - Appropriate tags for your environment

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `dns_zone_name`: Name of your DNS zone
- `dns_zone_resource_group_name`: Resource group containing the DNS zone
- `record_name`: Name of the DNS record
- `record_type`: Type of DNS record (A, AAAA, CNAME, MX, NS, TXT, SRV)
- `records`: List of record values

### Supported Record Types

The basic example supports all standard DNS record types:
- **A**: IPv4 addresses
- **AAAA**: IPv6 addresses
- **CNAME**: Canonical name records
- **TXT**: Text records (SPF, DKIM, verification, etc.)
- **MX**: Mail exchange records
- **NS**: Name server records
- **SRV**: Service records

### Example Configurations

#### A Record (Default)
```hcl
record_name = "www"
record_type = "A"
records     = ["203.0.113.1", "203.0.113.2"]
```

#### CNAME Record
```hcl
record_name = "blog"
record_type = "CNAME"
records     = ["blog.example.org."]
```

#### TXT Record
```hcl
record_name = "@"
record_type = "TXT"
records     = ["v=spf1 include:_spf.google.com ~all"]
```

## Clean Up

To remove the DNS record:
```bash
terraform destroy
```

**Note**: This will remove the DNS record from your zone. Ensure this won't disrupt services before proceeding.