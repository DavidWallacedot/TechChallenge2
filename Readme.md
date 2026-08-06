TechChallenge2

A production-style DevOps project demonstrating Infrastructure as Code, CI/CD, GitOps, containerization, and Kubernetes deployment on AWS.

## Technologies

- AWS
- Terraform
- Amazon EKS
- Amazon ECR
- Docker
- Kubernetes
- Helm
- Jenkins
- Argo CD
- GitHub Actions (OIDC)
- AWS Load Balancer Controller
- Horizontal Pod Autoscaler

---

# Architecture

Terraform provisions the complete AWS infrastructure.

```
                GitHub
                   │
         ┌─────────┴─────────┐
         │                   │
     Jenkins            Argo CD
         │                   │
         └─────────┬─────────┘
                   │
                Amazon EKS
                   │
             Kubernetes Pods
                   │
             ClusterIP Service
                   │
        AWS Load Balancer Controller
                   │
        Internet-facing ALB
                   │
                Application
```

---

# Repository Structure

```
.
├── app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── helm/
│   └── techchallenge2/
        ├── Chart.yaml
        ├── templates
        │   ├── deployment.yaml
        │   ├── hpa.yaml
        │   ├── ingress.yaml
        │   ├── namespace.yaml
        │   └── service.yaml
        └── values.yaml
│
├── k8s/
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── namespace.yaml
│   ├── service.yaml
│   └── hpa.yaml
│
├── terraform/
    ── alb-controller-helm.tf
    ├── alb-controller-iam.tf
    ├── alb-controller-irsa.tf
    ├── ecr.tf
    ├── eks.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── sg.json
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── terraform.tfvars
    ├── variables.tf
    ├── versions.tf
    └── vpc.tf
│
├── jenkins
        ..
        Dockerfile
        Jenkinsfile
        docker-compose.yml
        plugins.txt
│
└── README.md
```

---

# Branches

| Branch        | Purpose                         |
| ------------- | ------------------------------- |
| main          | Infrastructure                  |
| jenkins       | Jenkins CI/CD deployment        |
| gitops-argocd | GitOps deployment using Argo CD |

---

# Prerequisites

Install:

- AWS CLI
- Terraform
- kubectl
- Docker
- Git

Configure AWS credentials:

```bash
aws configure
```

---

# Clone Repository

```bash
git clone https://github.com/DavidWallacedot/TechChallenge2.git

cd TechChallenge2
```

---

# Provision Infrastructure

Switch to the infrastructure branch.

```bash
git checkout main
```

Initialize Terraform.

```bash
cd terraform

terraform init
```

Review the deployment.

```bash
terraform plan
```

Provision AWS infrastructure.

```bash
terraform apply
```

Terraform provisions:

- VPC
- Public Subnets
- Private Subnets
- NAT Gateway
- Internet Gateway
- Route Tables
- Security Groups
- Amazon EKS
- Managed Node Group
- Amazon ECR
- Jenkins EC2 Instance
- IAM Roles
- IAM Policies
- IAM Instance Profiles
- AWS Load Balancer Controller
- Metrics Server

After completion verify:

```bash
kubectl get nodes
```

---

# Deploy using the Jenkins Branch

Switch branches.

```bash
git checkout jenkins
```

Open Jenkins up in browswer

```
http://<JENKINS_PUBLIC_IP>:8080
```

Create a Pipeline Job.

Pipeline configuration:

Definition

```
Pipeline script from SCM
```

SCM

```
Git
```

Repository

```
https://github.com/DavidWallacedot/TechChallenge2.git
```

Branch

```
*/jenkins
```

Script Path

```
Jenkinsfile
```

Enable:

```
GitHub hook trigger for GITScm polling
```

Run:

```
Build Now
```

Pipeline stages:

1. Checkout
2. Prepare Image Variables
3. Build Docker Image
4. Push Image to Amazon ECR
5. Configure EKS Access
6. Deploy with Helm
7. Verify Deployment

After completion verify:

```bash
kubectl get pods -A
```

After the Jenkins pipeline completes successfully, the application is deployed to Amazon EKS using Helm.

To find the application's public URL, locate the Kubernetes Ingress that was created by the deployment:

```bash
kubectl get ingress -A
```

or, if using a dedicated namespace:

```bash
kubectl get ingress -n techchallenge2-jenkins
```

Example output:

```text
NAME                     CLASS   HOSTS   ADDRESS                                                                    PORTS   AGE
techchallenge2-ingress   alb     *       k8s-techchal-techchal-26c2d34101-1824373461.us-east-2.elb.amazonaws.com   80      2m
```

The value in the **ADDRESS** column is the DNS name of the AWS Application Load Balancer created by the AWS Load Balancer Controller.

Open the application in your browser:

```text
http://k8s-techchal-techchal-26c2d34101-1824373461.us-east-2.elb.amazonaws.com
```

If the **ADDRESS** field is empty (`<pending>`), AWS is still provisioning the Application Load Balancer. Wait a few minutes and run the command again until the DNS name appears.

---

# Deploy using the GitOps / Argo CD Branch

Switch branches.

```bash
git checkout gitops-argocd
```

Deploy Kubernetes resources.

```bash
kubectl apply -f k8s/
```

\*\*\* NOTE IF YOU WERE TO RUN JENKINS SECOND YOU WOULD APPLY THE K8 MANIFEST FILES AFTER SWITCHING TO THE BRANCH

Verify resources.

```bash
kubectl get pods,svc,ingress,hpa -n techchallenge2
```

Wait for the Ingress.

```bash
kubectl get ingress -n techchallenge2
```

Example output:

```
ADDRESS

k8s-techchallenge-xxxxxxxx.us-east-2.elb.amazonaws.com
```

Visit

```
http://<ALB DNS NAME>
```

---

# Destroy Infrastructure

Switch back to the infrastructure branch.

```bash
git checkout main
```

Navigate into Terraform.

```bash
cd terraform
```

Destroy AWS resources.

```bash
terraform destroy
```

Terraform removes:

- Jenkins EC2
- Amazon EKS
- Managed Node Groups
- Amazon ECR
- IAM Resources
- VPC
- Security Groups
- Internet Gateway
- NAT Gateway
- Load Balancers
- Route Tables
- Subnets

---

# Terraform Overview

Terraform provisions the complete AWS infrastructure required for the project.

## Networking

Creates:

- VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables

This allows public access to Jenkins while keeping Kubernetes worker nodes in private subnets.

---

## Amazon EKS

Creates:

- EKS Control Plane
- Managed Node Group
- Cluster Security Groups
- IAM Roles
- Access Entries

The cluster is configured for Kubernetes workloads running on managed EC2 worker nodes.

---

## Jenkins

Terraform provisions:

- Amazon Linux 2023 EC2 Instance
- Docker
- Docker Compose
- kubectl
- Helm
- AWS CLI

During provisioning the instance automatically:

- Configures kubeconfig
- Clones the Jenkins branch
- Builds the custom Jenkins Docker image
- Starts Jenkins using Docker Compose

---

## Amazon ECR

Creates a private ECR repository used by Jenkins to store application images.

---

## AWS Load Balancer Controller

Terraform installs:

- IAM Policy
- IAM Role
- IRSA Configuration
- Helm Release

This enables Kubernetes Ingress resources to automatically provision AWS Application Load Balancers.

---

## Metrics Server

Terraform installs the Kubernetes Metrics Server required by the Horizontal Pod Autoscaler.

---

# Jenkins Pipeline Overview

The Jenkins pipeline automates the application deployment process.

## Checkout

Downloads the latest source code from GitHub.

---

## Prepare Image Variables

Generates the Docker image tag using the current Git commit.

---

## Build Docker Image

Builds the Docker image from:

```
app/Dockerfile
```

---

## Push Image to Amazon ECR

Authenticates to Amazon ECR.

Tags the image.

Pushes the image into the ECR repository.

---

## Configure EKS Access

Updates kubeconfig using:

```
aws eks update-kubeconfig
```

allowing Jenkins to communicate with the Kubernetes cluster.

---

## Deploy with Helm

Runs:

```bash
helm upgrade --install
```

This creates or updates the Kubernetes Deployment, Service, and supporting resources.

---

## Verify Deployment

Verifies:

- Deployment rollout
- Running Pods
- Kubernetes Service
- Successful application deployment

---

# Horizontal Pod Autoscaler

The application is configured with an HPA.

Minimum replicas

```
2
```

Maximum replicas

```
5
```

Scaling is based on CPU utilization.

---

# AWS Load Balancer Controller

The application is exposed through an Internet-facing AWS Application Load Balancer.

Traffic flow:

```
Internet

↓

AWS ALB

↓

Ingress

↓

ClusterIP Service

↓

Pods
```

---

# CI/CD Workflow

```
Developer

↓

Git Push

↓

GitHub

↓

Jenkins Webhook

↓

Jenkins Pipeline

↓

Docker Build

↓

Amazon ECR

↓

Helm Upgrade

↓

Amazon EKS

↓

AWS Load Balancer

↓

Application
```

---

# GitOps Workflow

```
Developer

↓

Git Push

↓

GitHub Repository

↓

Argo CD

↓

Kubernetes Manifests

↓

Amazon EKS

↓

AWS Load Balancer

↓

Application
```
