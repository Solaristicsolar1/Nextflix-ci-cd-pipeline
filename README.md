# Netflix Clone - AWS CI/CD Pipeline with ECR

Deploy a Netflix clone React application on EC2 using Docker, ECR, and AWS DevOps tools.

## Architecture

**GitHub** → **CodeBuild** → **ECR** → **CodePipeline** → **CodeDeploy** → **EC2 Auto Scaling Group**

## AWS Services Used

- **GitHub**: Source code management
- **CodeBuild**: Build and containerize application
- **ECR**: Docker image repository
- **CodePipeline**: CI/CD orchestration
- **CodeDeploy**: Application deployment
- **Systems Manager**: Parameter storage
- **IAM**: Service roles and permissions
- **S3**: Build artifacts storage
- **EC2**: Application hosting
- **Auto Scaling Group**: High availability
- **Application Load Balancer**: Traffic distribution

## Prerequisites

1. **TMDB API Key**: Get from [The Movie Database](https://www.themoviedb.org/)
2. **AWS Account** with appropriate permissions
3. **GitHub Repository** with your Netflix clone code

## Setup Instructions

### 1. Create IAM Roles

**EC2 Role:**
```
Role Name: EC2CodeDeployRole
Trusted Entity: EC2
Policies: 
- AmazonEC2RoleforAWSCodeDeploy
- AmazonEC2ContainerRegistryReadOnly
- AmazonSSMManagedInstanceCore
```

**CodeDeploy Role:**
```
Role Name: CodeDeployServiceRole
Trusted Entity: CodeDeploy
Policies:
- AWSCodeDeployRole
```

### 2. Create ECR Repository

```bash
aws ecr create-repository --repository-name netflix-clone --region us-east-1
```

### 3. Store Parameters in Systems Manager

Create these parameters in **Parameter Store**:

| Parameter Name | Type | Value |
|---|---|---|
| `/myapp/ecr/repository-uri` | String | `YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/netflix-clone` |
| `/ecr/api/key` | SecureString | Your TMDB API Key |

### 4. Create Launch Template

**AMI**: Ubuntu 22.04 LTS
**Instance Type**: t3.micro (or larger)
**Security Group**: Allow SSH (22) and HTTP (80)
**IAM Role**: EC2CodeDeployRole

**User Data:**
```bash
#!/bin/bash
sudo apt update
sudo apt install -y docker.io ruby-full wget unzip
sudo systemctl start docker
sudo usermod -aG docker ubuntu
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
```

### 5. Create Auto Scaling Group

- **Launch Template**: Use the template created above
- **Desired Capacity**: 2
- **Min**: 1, Max: 4
- **Target Group**: Create new (HTTP:80)
- **Load Balancer**: Application Load Balancer

### 6. Create CodeBuild Project

**Project Configuration:**
- **Source**: GitHub (your repository)
- **Environment**: Ubuntu, Standard runtime
- **Service Role**: Create new (will auto-attach required policies)
- **Buildspec**: Use `buildspec.yaml` in repository root
- **Artifacts**: S3 bucket for storing build outputs
- **Privileged Mode**: ✅ Enable (required for Docker builds)

**Additional Permissions:**
Add `AmazonEC2ContainerRegistryPowerUser` policy to CodeBuild service role.

### 7. Create CodeDeploy Application

**Application Configuration:**
- **Application Name**: netflix-app
- **Compute Platform**: EC2/On-premises
- **Service Role**: CodeDeployServiceRole

**Deployment Group:**
- **Deployment Group Name**: netflix-deployment-group
- **Service Role**: CodeDeployServiceRole
- **Environment Configuration**: Amazon EC2 Auto Scaling groups
- **Auto Scaling Group**: Select your ASG
- **Load Balancer**: Enable load balancing

### 8. Create CodePipeline

**Pipeline Configuration:**
- **Pipeline Name**: netflix-cicd-pipeline
- **Service Role**: Create new

**Source Stage:**
- **Provider**: GitHub (Version 2)
- **Repository**: Your Netflix clone repository
- **Branch**: main
- **Change Detection**: ✅ Start pipeline on source code change

**Build Stage:**
- **Provider**: AWS CodeBuild
- **Project**: Your CodeBuild project
- **Build Type**: Single build

**Deploy Stage:**
- **Provider**: AWS CodeDeploy
- **Application**: netflix-app
- **Deployment Group**: netflix-deployment-group

## Project Files

### buildspec.yaml
Defines the build process:
- Installs Node.js dependencies
- Builds Docker image with TMDB API key
- Pushes image to ECR
- Creates deployment artifacts

### appspec.yml
Defines deployment process:
- Stops existing application
- Starts new application
- Validates deployment

### scripts/start.sh
- Installs AWS CLI if needed
- Pulls latest Docker image from ECR
- Starts Netflix container on port 80

### scripts/stop.sh
- Stops and removes existing Netflix container
- Cleans up Docker images

## Deployment Process

1. **Developer pushes code** to GitHub main branch
2. **CodePipeline triggers** automatically
3. **CodeBuild** builds Docker image and pushes to ECR
4. **CodeDeploy** deploys to EC2 Auto Scaling Group
5. **EC2 instances** pull image from ECR and start containers
6. **Load Balancer** distributes traffic to healthy instances

## Access Your Application

After successful deployment, access your Netflix clone at:
```
http://YOUR_LOAD_BALANCER_DNS_NAME
```

## Monitoring

- **CodePipeline**: Monitor pipeline execution
- **CodeBuild**: View build logs and status
- **CodeDeploy**: Track deployment progress
- **EC2**: Monitor instance health
- **Load Balancer**: Check target group health

## Troubleshooting

**Common Issues:**
- Ensure ECR repository URI is correct in Parameter Store
- Verify IAM roles have required permissions
- Check CodeDeploy agent is running on EC2 instances
- Confirm security groups allow HTTP traffic on port 80

## Clean Up

To avoid charges, delete resources in this order:
1. CodePipeline
2. CodeDeploy Application
3. CodeBuild Project
4. Auto Scaling Group
5. Load Balancer
6. Launch Template
7. ECR Repository
8. IAM Roles
9. Parameter Store parameters