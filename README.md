# AWS DocumentDB with Go Connector

This repository provides a one-click deployment solution for AWS DocumentDB and a Go application that connects to it. The solution automates the deployment of AWS DocumentDB and demonstrates how to connect to it using a Go application.

## Prerequisites

### AWS Requirements
- AWS account with appropriate permissions
- AWS CLI installed and configured with access credentials
- IAM permissions for:
  - DocumentDB (rds:*)
  - EC2 (ec2:CreateSecurityGroup, ec2:AuthorizeSecurityGroupIngress, ec2:CreateTags, etc.)
  - VPC and Subnet access
  - IAM role with sufficient permissions if running on EC2

### Software Requirements
- Terraform v1.0.0 or later
- Go v1.16 or later
- Git

### Network Requirements
- VPC with at least 3 subnets across different availability zones
- Internet connectivity for downloading dependencies

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/chiehchy/aws-docdb-go-connector.git
   cd aws-docdb-go-connector
   ```

2. Configure your deployment:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

3. Edit `terraform/terraform.tfvars` with your specific configuration:
   ```hcl
   aws_region = "ap-southeast-1"
   cluster_identifier = "my-docdb-cluster"
   master_username = "root"
   master_password = "YourStrongPasswordHere"
   instance_count = 2
   instance_class = "db.t3.medium"
   vpc_id = "vpc-07ad03be7b7e2cf0c"
   subnet_ids = [
     "subnet-03f8ad51d51c3da0e",
     "subnet-099d03d2d559004d4",
     "subnet-062b24149551fe782"
   ]
   allowed_cidr_blocks = ["10.0.0.0/16"]
   ```

4. Deploy the infrastructure:
   ```bash
   ./deploy.sh
   ```

5. The deployment script will:
   - Deploy DocumentDB using Terraform
   - Update the Go application with the correct connection string
   - Build and run the Go application to test the connection

## Repository Structure

```
.
├── README.md                   # This file
├── deploy.sh                   # One-click deployment script
├── terraform/                  # Terraform configuration files
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Terraform variables
│   ├── outputs.tf              # Terraform outputs
│   └── terraform.tfvars.example # Example variables file
└── app/                        # Go application
    ├── main.go                 # Go application code
    ├── go.mod                  # Go module file
    └── go.sum                  # Go dependencies
```

## Detailed Configuration

### Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region to deploy resources | ap-southeast-1 |
| cluster_identifier | Identifier for the DocumentDB cluster | my-docdb-cluster |
| master_username | Username for the DocumentDB master user | root |
| master_password | Password for the DocumentDB master user | (No default, must be specified) |
| instance_count | Number of DocumentDB instances to create | 2 |
| instance_class | Instance class for DocumentDB instances | db.t3.medium |
| vpc_id | VPC ID where DocumentDB will be deployed | (No default, must be specified) |
| subnet_ids | List of subnet IDs for DocumentDB subnet group | (No default, must be specified) |
| allowed_cidr_blocks | CIDR blocks allowed to connect to DocumentDB | ["10.0.0.0/16"] |

### Go Application

The Go application demonstrates:
- Connecting to DocumentDB with SSL
- Creating an index
- Performing CRUD operations (Create, Read, Update, Delete)
- Proper error handling

## Security Considerations

- **Password Security**: The default configuration uses a placeholder password. Replace it with a strong password in your `terraform.tfvars` file.
- **Network Security**: The security group allows access only from within the specified CIDR blocks.
- **SSL Encryption**: SSL is enabled for DocumentDB connections.
- **Production Recommendations**:
  - Use AWS Secrets Manager for credential management
  - Implement IAM authentication for DocumentDB
  - Consider using VPC endpoints for enhanced security
  - Enable audit logging for DocumentDB

## Troubleshooting

### Common Issues

1. **Terraform Permission Errors**:
   - Ensure your AWS credentials have sufficient permissions
   - For EC2 instances, ensure the IAM role has the necessary policies

2. **Connection Issues**:
   - Verify security group allows traffic from your application
   - Check that your VPC and subnet configuration allows connectivity
   - Ensure SSL certificates are properly configured

3. **Go Application Errors**:
   - Check that Go modules are properly initialized
   - Verify the connection string is correct
   - Ensure MongoDB driver is compatible with DocumentDB

## Cleanup

To remove all resources and avoid incurring charges:

```bash
cd terraform
terraform destroy -auto-approve
```

## Cost Considerations

- DocumentDB instances (db.t3.medium) cost approximately $0.078 per hour each
- Storage costs $0.10 per GB-month for the first 100 TB
- I/O costs $0.20 per 1 million requests
- Backup storage is free up to the size of your cluster

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Acknowledgments

- AWS DocumentDB documentation
- MongoDB Go Driver documentation
- Terraform AWS Provider documentation
