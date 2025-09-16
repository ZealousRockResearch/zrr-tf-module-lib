# Basic MySQL Firewall Rules Example

This example demonstrates basic usage of the MySQL Firewall Rule module for simple network access control scenarios.

## What This Example Creates

- Basic firewall rules for office network access
- Azure services access (optional)
- Standard enterprise tagging

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - MySQL server name and resource group
   - Your office IP ranges
   - Appropriate tags for your environment

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `mysql_server_name`: Name of your MySQL server
- `mysql_server_resource_group_name`: Resource group containing the MySQL server

### Example Firewall Rules

The basic example creates:
- Office network access (203.0.113.0/24)
- Management network access (198.51.100.0/24)
- Azure services access (if enabled)

### Security Considerations

- IP ranges should be as restrictive as possible
- Consider using specific IP addresses for development environments
- Enable Azure services access only if required by your applications
- Regular review of firewall rules is recommended

## Clean Up

To remove the firewall rules:
```bash
terraform destroy
```

**Note**: This will remove all firewall rules created by this module. Ensure this won't disrupt access to your MySQL server.