# Basic Network Security Group Example

This example demonstrates the basic usage of the Azure Network Security Group module.

## Features Demonstrated

- Creating a Network Security Group with basic security rules
- Configuring inbound rules for SSH and HTTP traffic
- Using common tags for resource management

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update the variables in `terraform.tfvars` according to your requirements
3. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 Network Security Group
- 2 Security Rules (SSH and HTTP)

## Security Rules

| Name | Priority | Direction | Access | Protocol | Ports | Description |
|------|----------|-----------|--------|----------|-------|--------------|
| allow-ssh | 1001 | Inbound | Allow | TCP | 22 | Allow SSH access |
| allow-http | 1002 | Inbound | Allow | TCP | 80 | Allow HTTP access |

## Clean up

To destroy the resources:

```bash
terraform destroy
```