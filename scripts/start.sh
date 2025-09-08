#!/bin/bash

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Set region
export AWS_DEFAULT_REGION=us-east-1

# Get ECR repository URI from parameter store
ECR_REPOSITORY_URI=$(aws ssm get-parameter --name "/myapp/ecr/repository-uri" --query "Parameter.Value" --output text --region $AWS_DEFAULT_REGION)

echo "ECR Repository URI: $ECR_REPOSITORY_URI"

# Stop and remove existing container if running
docker stop netflix 2>/dev/null || true
docker rm netflix 2>/dev/null || true

# Login to ECR
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI

# Pull and run the container
docker pull $ECR_REPOSITORY_URI:latest
docker run -d --name=netflix -p 80:80 $ECR_REPOSITORY_URI:latest

echo "Netflix container started successfully"