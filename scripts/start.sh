#!/bin/bash

# Get ECR repository URI from parameter store
ECR_REPOSITORY_URI=$(aws ssm get-parameter --name "/myapp/ecr/repository-uri" --query "Parameter.Value" --output text)

# Login to ECR
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI

# Pull and run the container
docker pull $ECR_REPOSITORY_URI:latest
docker run -d --name=netflix -p 80:80 $ECR_REPOSITORY_URI:latest
