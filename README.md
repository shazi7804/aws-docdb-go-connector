# AWS DocumentDB with Go Connector

This repository provides a one-click deployment solution for AWS DocumentDB and a Go application that connects to it. The solution automates the deployment of AWS DocumentDB and demonstrates how to connect to it using a Go application.

## Prerequisites

### AWS Requirements
- AWS account with appropriate permissions
- AWS CLI installed and configured with access credentials

### Required IAM Permissions

For successful deployment, your IAM user or role needs the following permissions:

#### DocumentDB Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBCluster",
        "rds:DeleteDBCluster",
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSubnetGroups",
        "rds:ModifyDBCluster",
        "rds:ModifyDBInstance",
        "rds:AddTagsToResource",
        "rds:ListTagsForResource",
        "rds:DescribeDBClusterParameters",
        "rds:DescribeDBClusterParameterGroups",
        "rds:CreateDBClusterParameterGroup",
        "rds:ModifyDBClusterParameterGroup",
        "rds:DeleteDBClusterParameterGroup"
      ],
      "Resource": "*"
    }
  ]
}
```

#### EC2 Permissions (for Security Groups and Network)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeRouteTables",
        "ec2:DescribeNetworkAcls"
      ],
      "Resource": "*"
    }
  ]
}
```


### Software Requirements
- Terraform v1.0.0 or later
- Go v1.16 or later
- Git

### Network Requirements
- VPC with at least 3 subnets across different availability zones
- Internet connectivity for downloading dependencies
- Subnets must have proper route tables configured for DocumentDB access
- Network ACLs must allow traffic on port 27017 (DocumentDB default port)

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
   vpc_id = "vpc-xxxx"
   subnet_ids = [
     "Subnet-xxxx",
     "Subnet-xxx",
     "Subnet-xxx"
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

### Advanced Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| engine_version | DocumentDB engine version | 4.0.0 |
| backup_retention_period | Number of days to retain backups | 7 |
| preferred_backup_window | Daily time range for backups (UTC) | "07:00-09:00" |
| skip_final_snapshot | Whether to skip final snapshot when destroying | true |
| deletion_protection | Enable deletion protection | false |
| apply_immediately | Apply changes immediately or during maintenance window | true |
| enabled_cloudwatch_logs_exports | Log types to export to CloudWatch | ["audit", "profiler"] |

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
  - Use a custom parameter group with secure settings
  - Implement network isolation with private subnets
  - Use encryption at rest with a customer-managed KMS key

## Troubleshooting

### Common Issues

1. **Terraform Permission Errors**:
   - Ensure your AWS credentials have sufficient permissions (see IAM permissions section)
   - For EC2 instances, ensure the IAM role has the necessary policies
   - Check CloudTrail logs for specific permission denials

2. **Connection Issues**:
   - Verify security group allows traffic from your application
   - Check that your VPC and subnet configuration allows connectivity
   - Ensure SSL certificates are properly configured
   - Verify that the DocumentDB cluster is in the 'available' state
   - Check that your application has network access to the DocumentDB endpoint

3. **Go Application Errors**:
   - Check that Go modules are properly initialized
   - Verify the connection string is correct
   - Ensure MongoDB driver is compatible with DocumentDB
   - Check for SSL/TLS configuration issues
   - Verify that the MongoDB driver version is compatible with DocumentDB

4. **Deployment Failures**:
   - Check Terraform state for detailed error messages
   - Verify that your VPC has sufficient IP addresses available
   - Ensure that you're not hitting service quotas/limits
   - Check that the specified subnets are in different availability zones

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
- Data transfer costs vary by region and destination
- CloudWatch logs incur additional charges if enabled


## Acknowledgments

- AWS DocumentDB documentation
- MongoDB Go Driver documentation
- Terraform AWS Provider documentation
