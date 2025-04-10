#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AWS DocumentDB with Go Connector - Deployment Script${NC}"
echo "=================================================="

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials are not configured or invalid. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

# Check Go
if ! command -v go &> /dev/null; then
    echo -e "${RED}Go is not installed. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}All prerequisites are met!${NC}"

# Setup Terraform variables
echo -e "${YELLOW}Setting up Terraform variables...${NC}"
if [ ! -f terraform/terraform.tfvars ]; then
    echo "Creating terraform.tfvars from example file..."
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    echo -e "${YELLOW}Please edit terraform/terraform.tfvars with your specific configuration and run this script again.${NC}"
    exit 0
fi

# Initialize and apply Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
cd terraform
terraform init

echo -e "${YELLOW}Deploying AWS DocumentDB with Terraform...${NC}"
terraform apply -auto-approve

# Get DocumentDB connection details
echo -e "${YELLOW}Getting DocumentDB connection details...${NC}"
CONNECTION_STRING=$(terraform output -raw connection_string)
cd ..

# Build and run Go application
echo -e "${YELLOW}Building and running Go application...${NC}"
cd app
go mod tidy
export DOCDB_CONNECTION_STRING="$CONNECTION_STRING"
go run main.go

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}DocumentDB is now running and the Go application has connected to it.${NC}"
echo -e "${YELLOW}To clean up resources, run: cd terraform && terraform destroy -auto-approve${NC}"
