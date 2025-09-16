# Basic DNS Zone Example

This example demonstrates how to create a basic Azure DNS Zone with essential A and CNAME records.

## What This Example Creates

- Public DNS zone for a domain
- Basic A records for web services
- CNAME record for blog subdomain
- Standard resource tagging

## Usage

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   zone_name           = "yourdomain.com"
   resource_group_name = "your-dns-rg"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Example Configuration

```hcl
module "dns_zone_basic" {
  source = "../../"

  name                = "example-basic.com"
  resource_group_name = "dns-basic-rg"

  a_records = [
    {
      name    = "www"
      ttl     = 3600
      records = ["1.2.3.4"]
    }
  ]

  cname_records = [
    {
      name   = "blog"
      ttl    = 3600
      record = "www.example-basic.com"
    }
  ]

  common_tags = {
    Environment = "development"
    Project     = "dns-basic-example"
  }
}
```

## Outputs

After successful deployment, you'll get:

- `dns_zone_id`: The Azure resource ID of the DNS zone
- `dns_zone_name`: The domain name of the zone
- `name_servers`: List of Azure DNS name servers
- `a_records`: Information about created A records
- `cname_records`: Information about created CNAME records

## DNS Records Created

| Record Type | Name | TTL | Target |
|-------------|------|-----|--------|
| A | www | 3600 | 1.2.3.4 |
| A | api | 300 | 5.6.7.8 |
| CNAME | blog | 3600 | www.example-basic.com |

## Next Steps

For more advanced configurations, see the [advanced example](../advanced/) which includes:

- Multiple record types (MX, TXT, SRV, PTR)
- DNS delegation
- Virtual network integration
- Monitoring and alerting
- DNSSEC configuration