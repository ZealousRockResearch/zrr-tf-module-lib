# Advanced Container Instance Example

This example demonstrates the full capabilities of the Azure Container Instance module with comprehensive enterprise features including multi-container deployments, private networking, persistent storage, monitoring, and security configurations.

## What This Example Creates

- **Multi-Container Group**: Frontend, backend, and sidecar logging containers
- **Private Networking**: VNet integration for secure deployments
- **Persistent Storage**: Azure Files shares, Git repositories, and secret volumes
- **Container Registry**: Integration with Azure Container Registry and external registries
- **Health Monitoring**: Liveness and readiness probes for all containers
- **Enterprise Logging**: Centralized logging with Log Analytics and alerting
- **Managed Identity**: System-assigned identity for Azure service authentication
- **Security Features**: Secure environment variables and network isolation

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                Container Group                          │
├─────────────────┬─────────────────┬─────────────────────┤
│   Frontend      │    Backend      │   Sidecar Logger    │
│   (nginx/react) │   (node.js)     │   (fluent-bit)      │
│   Port: 3000    │   Port: 8080    │   Logging only      │
├─────────────────┼─────────────────┼─────────────────────┤
│ Health Checks   │ Health Checks   │ Log Aggregation     │
│ Config Volumes  │ Data Volumes    │ Config Volumes      │
│ Public Traffic  │ Internal API    │ Log Forwarding      │
└─────────────────┴─────────────────┴─────────────────────┘
                          │
                    ┌─────┴─────┐
                    │   VNet    │
                    │Integration│
                    └───────────┘
```

## Usage

1. **Prerequisites Setup**:
   ```bash
   # Ensure you have:
   # - Azure CLI installed and logged in
   # - Container registry with images
   # - Virtual network and subnet (for private deployment)
   # - Storage account for persistent volumes
   # - Action Group for monitoring alerts
   ```

2. **Copy and Configure**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit Configuration**:
   ```hcl
   # Update with your actual values
   container_name      = "my-microservices-app"
   resource_group_name = "my-container-rg"

   # Configure your container registry
   container_registry_name = "myregistry"

   # Configure networking (for private deployment)
   subnet_id = "/subscriptions/.../subnets/container-subnet"

   # Configure monitoring
   action_group_id = "/subscriptions/.../actionGroups/my-alerts"
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Container Configuration

### Frontend Container
- **Purpose**: Web application frontend (React, Angular, etc.)
- **Image**: Custom application image from registry
- **Resources**: 1 CPU, 2 GB memory
- **Health Checks**: HTTP-based liveness and readiness probes
- **Volumes**: Shared configuration from Git repository

### Backend Container
- **Purpose**: API server and business logic
- **Image**: Node.js application with API endpoints
- **Resources**: 0.5 CPU, 1 GB memory
- **Security**: Secure environment variables for sensitive data
- **Storage**: Persistent data volume and shared configuration
- **Health Checks**: API endpoint health monitoring

### Sidecar Logger Container
- **Purpose**: Log aggregation and forwarding
- **Image**: Fluent Bit for log processing
- **Resources**: 0.1 CPU, 0.25 GB memory (minimal overhead)
- **Function**: Collects and forwards application logs
- **Configuration**: Custom logging rules via config volumes

## Volume Configuration

### Persistent Storage (Azure Files)
```hcl
volumes = [
  {
    name                 = "app-data"
    storage_account_name = "mycompanystorage"
    storage_account_key  = "storage-key"
    share_name          = "microservices-data"
  }
]
```

### Git Repository Configuration
```hcl
volumes = [
  {
    name = "app-source"
    git_repo = {
      url       = "https://github.com/company/config.git"
      directory = "production-config"
      revision  = "v2.1.0"
    }
  }
]
```

### Secret Management
```hcl
volumes = [
  {
    name = "app-secrets"
    secret = {
      "database.json"     = base64encode(jsonencode({
        host     = "db.company.com"
        username = "app_user"
      }))
      "api-keys.json"     = base64encode(jsonencode({
        api_key = "secret-key"
      }))
    }
  }
]
```

## Network Configuration

### Private VNet Integration
```hcl
ip_address_type = "Private"
subnet_id       = "/subscriptions/.../subnets/container-subnet"

dns_config = {
  nameservers    = ["10.0.0.4", "10.0.0.5"]
  search_domains = ["internal.company.com"]
  options        = ["ndots:2", "edns0"]
}
```

### Public Access (Alternative)
```hcl
ip_address_type = "Public"
dns_name_label  = "my-microservices-app"

exposed_ports = [
  {
    port     = 3000
    protocol = "TCP"
  }
]
```

## Health Monitoring

### Liveness Probes
```hcl
liveness_probe = {
  http_get = [
    {
      path = "/health"
      port = 3000
    }
  ]
  initial_delay_seconds = 30
  period_seconds       = 10
  failure_threshold    = 3
}
```

### Readiness Probes
```hcl
readiness_probe = {
  http_get = [
    {
      path = "/ready"
      port = 3000
    }
  ]
  initial_delay_seconds = 5
  period_seconds       = 5
  failure_threshold    = 3
}
```

## Security Features

### Managed Identity
```hcl
managed_identity = {
  type = "SystemAssigned"
}
```

The system-assigned identity can be used to:
- Access Azure Key Vault for secrets
- Connect to Azure SQL Database
- Access other Azure services without storing credentials

### Secure Environment Variables
```hcl
secure_environment_variables = {
  DATABASE_PASSWORD = "secure-password"
  API_SECRET_KEY   = "secret-key"
  JWT_SECRET       = "signing-secret"
}
```

## Monitoring and Alerting

The advanced example includes:

### Log Analytics Integration
- Centralized logging for all containers
- Custom log queries and dashboards
- 90-day log retention for compliance

### Metric Alerts
- **CPU Usage**: Alert when CPU > 80%
- **Memory Usage**: Alert when memory > 85%
- **Custom Metrics**: Application-specific monitoring

### Alert Actions
- Email notifications to operations team
- Webhook integration with incident management
- Azure Logic Apps for automated responses

## Container Registry Integration

### Azure Container Registry
```hcl
container_registry_name = "mycompanyregistry"
```

### Multiple Registry Support
```hcl
additional_image_registries = [
  {
    server   = "docker.io"
    username = "dockerhub-user"
    password = "access-token"
  },
  {
    server   = "private.company.com"
    username = "company-user"
    password = "company-token"
  }
]
```

## Performance Optimization

### Resource Allocation
- **Frontend**: Higher memory for client-side processing
- **Backend**: Balanced CPU/memory for API processing
- **Sidecar**: Minimal resources for logging overhead

### Health Check Tuning
- **Initial Delays**: Account for application startup time
- **Check Intervals**: Balance responsiveness vs. resource usage
- **Failure Thresholds**: Prevent false positives during traffic spikes

## Scaling Considerations

While Container Instances don't auto-scale, this architecture supports:

### Horizontal Scaling
- Deploy multiple container groups behind a load balancer
- Use Azure Container Apps for auto-scaling scenarios
- Implement blue-green deployments

### Vertical Scaling
- Adjust CPU and memory allocation based on monitoring
- Use different SKUs for development vs. production
- Optimize resource allocation per container role

## Cost Optimization

### Resource Right-Sizing
- Monitor actual resource usage vs. allocation
- Adjust CPU/memory based on performance metrics
- Use appropriate restart policies

### Storage Optimization
- Use empty directories for temporary data
- Implement log rotation for persistent volumes
- Choose appropriate storage tiers

## Troubleshooting

### Common Issues and Solutions

1. **Container Startup Failures**:
   ```bash
   # Check container logs
   az container logs --resource-group my-rg --name my-container --container-name frontend
   ```

2. **Network Connectivity Issues**:
   ```bash
   # Verify subnet delegation
   az network vnet subnet show --name container-subnet --vnet-name main-vnet --resource-group network-rg
   ```

3. **Storage Mount Problems**:
   ```bash
   # Verify storage account access
   az storage share show --name microservices-data --account-name mycompanystorage
   ```

4. **Registry Authentication Failures**:
   ```bash
   # Test registry connectivity
   az acr login --name mycompanyregistry
   ```

## Next Steps

After successful deployment:

1. **Set up monitoring dashboards** in Azure Monitor
2. **Configure automated deployments** with Azure DevOps
3. **Implement backup strategies** for persistent data
4. **Plan disaster recovery** across regions
5. **Consider migration** to Azure Container Apps for production scaling

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: Ensure you backup any persistent data before cleanup.