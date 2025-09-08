#!/bin/bash

# Set region
export AWS_DEFAULT_REGION=us-east-1

# Get ECR repository URI from parameter store
ECR_REPOSITORY_URI=$(aws ssm get-parameter --name "/myapp/ecr/repository-uri" --query "Parameter.Value" --output text --region $AWS_DEFAULT_REGION 2>/dev/null)

# Stop and remove container
docker stop netflix 2>/dev/null || true
docker rm netflix 2>/dev/null || true

# Remove ECR image if URI was retrieved successfully
if [ ! -z "$ECR_REPOSITORY_URI" ]; then
    docker image rm $ECR_REPOSITORY_URI:latest 2>/dev/null || true
    echo "Stopped netflix container and removed ECR image"
else
    echo "Stopped netflix container (could not retrieve ECR URI)"
fi