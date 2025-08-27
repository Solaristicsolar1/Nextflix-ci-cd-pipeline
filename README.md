# AWS DevOps CICD Pipeline

In This Project, we are Developing and Deploying a video streaming application on EC2 using Docker and AWS Developers Tools.

* `Github`: For Source Code Management

* `CodeBuild`: For building and testing our code in a serverless fashion

* `CodeDeploy`: To deploy our code

* `CodePipeline`: To streamline the CI/CD pipeline

* `System Manager`: To store Parameters

* `DockerHub`: To store Docker Images in a Repository

* `Identity and Access Management` (IAM) for creating a Service Role

* `S3` for artifact storing

* `EC2` for Deployment

Clone this Repository

```elixir
git clone https://github.com/OjoOluwagbenga700/Netflix-Clone--aws-cicd-pipeline-on-ec2.git
```

# **Project Architecture**

# **draw your architecture here**


### 1. IAM Role Configuration

#### EC2 Role
1. Create a new role with EC2 as trusted entity
2. Attach `AmazonEC2RoleforAWSCodeDeploy` policy
3. Name the role (e.g., `EC2CodeDeployRole`)

#### CodeDeploy Role
1. Create a new role with CodeDeploy as trusted entity
2. Attach `AWSCodeDeployRole` policy
4. Update trust relationship with provided policy

### 2. Launch Template and ASG setup

1. Use Ubuntu or Amazon linux  EC2 instance for Launch Template
2. Configure security group (SSH: Port 22, HTTP: Port 80)
3. Attach EC2CodeDeployRole
4. Add CodeDeploy agent installation script to user data
5. Create autoscaling group from the launch template
6. Create loadbalancer and target group as part of the autoscalling group.

### UserData (ensure you change region to your current region for the codedeploy agent)
* For `Amazon Linux`
```yaml
#!/bin/bash
sudo yum -y update
sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user
sudo yum -y install ruby
sudo yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
```

* For `Ubuntu`
```yaml
#!/bin/bash
sudo apt update
sudo install docker.io
sudo apt install ruby-full
wget cd /home/ubuntu wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent status
```

* In this project, we will build and push a Docker image to the DockerHub repository.

* So, We need DockerHub credentials like `Username` and `Password`.

* Also, we are using a free API to consume movie/TV data in this Project. [TMDB](https://www.themoviedb.org/).
* Click on the TMDB link , create and account and get your API Key (TMDB API key)

* # **Using** `AWS System Manager` for storing secrets

* Goto `AWS System Manager` dashboard.

* Click on `Parameter Store` -&gt; `Create parameter`

* In Parameter details

***Add*** `DockerHub Username`

*Name:* `/myapp/docker-credentials/username`

*Type:* `SecureString`

*Value: Add Your DockerHub Username*

***Add*** `DockerHub Password`

*Name:* `/myapp/docker-credentials/password`

*Type:* `SecureString`

*Value: Add Your DockerHub Password or secret token*

***Add*** `TMDB API Key`

*Name:* `/myapp/api/key`

*Type:* `SecureString`

*Value: Add Your TMDB API key*

# **Setting Up CodeBuild**

* Click on `Create build project`

* Follow the steps

* CodeBuild will need `buildspec.yml` to build a project.
  
* Add source - Github
  
* Add Artifact - S3 ( create s3 bucket)

* The `buildspec.yml` file is in the repository root folder.

* Also, This project will containerize so that select the `Enable this flag if you want to build Docker images or want your builds to get elevated privileges.`

* Also, Add Permission in CodeBuild Created Role to assess `Parameters from CodeBuild to System Manager`

* For this, Attach `AmazonSSMManagedInstanceCore `policy to the codebuild created role


# **DockerHub Repository**

* Just for Test

* `Pull` this Docker Image locally using `docker run -n netflix -p 8080:80 your-dockehub-username/netflix-react-app`

![](https://miro.medium.com/v2/resize:fit:802/1*84WPkjw5a1ddu8QS7Brx7g.png)

# **Create CodeDeploy Application**

* Create Application and Compute platform is EC2/On-premises
  
* Add Service role (codedeployrole created above)
  
* Create CodeDeploy Group
  
* select  Amazon EC2 autoscaling group under environmnent configuration

* Click On `Create Deployment` to `Start Deployment`


# **Create CodePipeline**

* Step 1: Choose pipeline setting -&gt; PipelineName &gt; Service role

* Step 2: Add source stage -&gt; Github &gt; RepoName &gt; BranchName &gt; Select CodePipeline periodically for changes(For automation)

* Step 3: Add build stage -&gt; BuildProvider &gt; Region &gt; ProjectName &gt; Single build

* Step 4: Add deploy stage -&gt; DeployProvider &gt; Region &gt; AppName &gt; Deployment group

* Step 5: Review



# **Output**

Check your output from the DNS endpoint of your loadbalancer

![](https://miro.medium.com/v2/resize:fit:1146/1*AXXMABbwjT5zFi5zibzP5A.png)


# Netflix-Clone--aws-cicd-pipeline-on-ec2-asg
