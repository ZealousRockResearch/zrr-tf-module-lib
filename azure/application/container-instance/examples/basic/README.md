# Basic Container Instance Example

This example demonstrates how to create a basic Azure Container Instance with a simple web server container.

## What This Example Creates

- Public container instance with a single nginx container
- Public IP address with DNS name
- Basic resource tagging
- Simple container configuration

## Usage

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   container_name      = "my-web-container"
   resource_group_name = "my-container-rg"
   dns_name_label      = "my-unique-web-app"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Example Configuration

```hcl
module "container_instance_basic" {
  source = "../../"

  name                = "basic-container-example"
  location            = "East US"
  resource_group_name = "container-basic-rg"

  containers = [
    {
      name   = "nginx-web"
      image  = "nginx:latest"
      cpu    = 1
      memory = 1.5
      ports = [
        {
          port     = 80
          protocol = "TCP"
        }
      ]
    }
  ]

  ip_address_type = "Public"
  exposed_ports = [
    {
      port     = 80
      protocol = "TCP"
    }
  ]

  common_tags = {
    Environment = "development"
    Project     = "container-basic-example"
  }
}
```

## Outputs

After successful deployment, you'll get:

- `container_group_id`: The Azure resource ID of the container group
- `container_group_name`: The name of the container group
- `ip_address`: The public IP address assigned to the container
- `fqdn`: The fully qualified domain name for accessing the container
- `dns_name_label`: The DNS name label used

## Container Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| Container Name | nginx-web | Name of the container |
| Image | nginx:latest | Docker image to run |
| CPU | 1 core | CPU allocation |
| Memory | 1.5 GB | Memory allocation |
| Port | 80/TCP | Exposed port |

## Accessing Your Container

Once deployed, you can access your container using:

1. **Public IP**: Use the `ip_address` output
2. **DNS Name**: Use the `fqdn` output (e.g., `basic-container-demo.eastus.azurecontainer.io`)

Example:
```bash
curl http://basic-container-demo.eastus.azurecontainer.io
```

## Customization Options

You can customize this example by modifying:

### Container Image
```hcl
containers = [
  {
    name   = "my-app"
    image  = "your-registry/your-app:v1.0"
    cpu    = 1
    memory = 1.5
  }
]
```

### Environment Variables
```hcl
containers = [
  {
    name   = "my-app"
    image  = "nginx:latest"
    cpu    = 1
    memory = 1.5
    environment_variables = {
      ENV_VAR_1 = "value1"
      ENV_VAR_2 = "value2"
    }
  }
]
```

### Resource Allocation
```hcl
containers = [
  {
    name   = "my-app"
    image  = "nginx:latest"
    cpu    = 2      # Increase CPU to 2 cores
    memory = 4      # Increase memory to 4 GB
  }
]
```

## Next Steps

For more advanced configurations, see the [advanced example](../advanced/) which includes:

- Multi-container deployments
- Private networking with VNet integration
- Container registry authentication
- Persistent storage volumes
- Health checks and monitoring
- Managed identity configuration
- GPU support for ML workloads

## Cleanup

To destroy the resources:
```bash
terraform destroy
```