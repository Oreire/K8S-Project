# K8S-Project undertaken at TechBleat

# Project Summary:

This project is a hands-on implementation of the automation of the provisioning and deployment of a Kubernetes cluster and its associated resources using  **Terraform**, **GitHub Actions**, and **AWS EKS**. A structured approach was utilized for the infrastructure provisioning and services deployment in line with DevOps best practices.


## 📌 Project Deliverables

1. **Provisioned a 3-node Kubernetes Cluster (Pro8-cluster) on AWS (EKS)** using t2.micro EC2 instances.

2. **Deployed services**:

   - ✅ Two (2) NGINX instances (Deployment) with a **LoadBalancer Service**

   - ✅ One (1) Prometheus instance (Deployment) with a **LoadBalancer Service**

   - ✅ One (1) Prometheus Node Exporter (DaemonSet) with a **ClusterIP Service**

3. **Project AWS Networking** infrastructure using Terraform:

   - KubNet (VPC), 2 Public Subnets, 2 Private Subnets, IGW and Route Tables amongst others.

4. **Build a CI/CD pipeline using GitHub Actions** for:
   - The Automation of Networking Infrastructure provisioning using Terraform .
   - Automation of cluster nodes, ASG and NodeGroups etc

5. **Manual Provisioning of K8S resources via YAML manifests files**


# Techinical overview of the **K8S Project**:


### **1. **Prerequisites**:

- AWS Account 

- Configured AWS access credentials

- GitHub Actions Workflows

- Terraform CLI on Vscode

- Inject worflow with Environment variables:**AWS_ACCESS_KEY_ID**`, `**KUBECONFIG**` and `**env.AWS_REGION**.


### **2. **Infrastructure Setup**:

- **Purpose**: Automating the infrastructure setup.

- **Terraform Pipeline**:
  
  - **Provisioned VPC (KubNet) (192.168.0.0/16)** with associated components including public & private 
      subnets (**192.168.0.0/24**) across 2 AZs (**eu-west-2a & eu-west-2b**) and internet gateway.
  
  - Created a **3-node EKS** (Elastic Kubernetes Service) cluster and supporting **CloudFormation stacks**.
  
  - Outputs included VPC, private and public subnet details as well as VPC (KubNet) identifiers.
  
     
   
### **3. Kubernetes Cluster and Resources**:

- **Cluster Details**:
  - Named `Pro8-cluster`.
  - Comprises 3 nodes, provisioned using CloudFormation templates managed by `eksctl`.
  - IAM roles and policies were appropriately configured for cluster access.

- **Node Groups**:
  - Auto-scaling group provisioned with a desired capacity of 3 nodes (minimum 3, maximum 5).
  - Nodes deployed to two availability zones (**eu-west-2a** and **eu-west-2b**).


### **4. Kubernetes Resource Deployment**:

- **Challenges**:
  - Automation of deployments and services via GitHub Actions encountered issues and was ultimately handled  
    manually.
  - Manual steps involved cloning the repository locally and applying manifests via `kubectl` commands.
  
- **Manually Deployed Kubernetes Resources**:
  
  - **Deployments**:
    
    - **Nginx Deployment**: 2 replica pods created successfully.
    - **Prometheus Deployment**: Single pod deployment encountered issues due to readiness.
    - **Node Exporter DaemonSet**: Facilitated system-level monitoring across all nodes.

  - **Services**:
    
    - **Nginx Service**: Exposed using a LoadBalancer.
    - **Prometheus Service**: Exposed using a LoadBalancer.
    - **Node Exporter Service**: Exposed via ClusterIP.

  - **Overview of Deployments and Services**
  ---------------------------------------------------------------------------
  | **Component**       | **Type**   | **Instance(s)**  |  **Service Type** |
  |---------------------|-------------------------------|-------------------|
  | NGINX               | Deployment |        2         |  LoadBalancer     |
  |---------------------|------------|------------------|-------------------|
  | Prometheus          | Deployment |        1         |  LoadBalancer     |
  |---------------------|------------|------------------|-------------------|
  | Node Exporter       | DaemonSet  |        1         |  ClusterIP        |
  ---------------------------------------------------------------------------

- **NGINX services in public subnets** behind an Application Load Balancer

- **Monitoring stack (Prometheus + Node Exporter)** in private subnets

### **5. Testing and Observations**:

- **Availability and Scalability**: 

  - Deployment resources were tested to validate fault tolerance.
  
  - Verified cluster functionality with tests for high availability and resilience.

- **Provisioned Services**:

  - Services mapped to external endpoints for browser access, utilizing AWS Elastic Load Balancer DNS.

  - Utilized LoadBalancer and ClusterIP services for external and internal pod communication.

   
### **6. IAM and Security**:

 - # Implemented appropriate IAM policies for cluster access and resource control.

 - # Attached IAM policies included consist of but not limited to:

    - Amazon-managed policies for EC2, EKS, and VPC access.

    - Inline custom policies for cluster-specific requirements.

    - Created Kube-Cluster-policy, CloudFormation-policies && EC2-DESCRIBE-VPC 


### **7. Challenges Highlighted**:
    
-  GitHub Actions pipeline failed to automate deployments and services due to OpenAPI connection issues and 
   validation failures.

# LATEST CODES TO TEST

name: Deploy EKS Cluster and Kubernetes Resources

on:
  push:
    branches:
      - main

jobs:
  setup-eks-cluster:
    name: Setup EKS Cluster
    runs-on: ubuntu-latest

    env:
      AWS_REGION: eu-west-2

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Install awscli
      run: |
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        aws --version

    - name: Install eksctl
      run: |
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.149.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
        eksctl version

    - name: Configure AWS CLI
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: |
        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
        aws configure set region $AWS_REGION

    - name: Create EKS cluster
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: |
        eksctl create cluster \
          --name laredo-cluster \
          --region $AWS_REGION \
          --vpc-id "vpc-08a17b6e2ca297b74" \
          --vpc-private-subnets "subnet-02bde47502fb02125,subnet-0f59c570adae02aea" \
          --vpc-public-subnets "subnet-083c61532e8a7d397,subnet-04555ba84be05c2ba" \
          --nodegroup-name my-kube-nodes \
          --node-type t2.small \
          --nodes 3 \
          --nodes-min 3 \
          --nodes-max 5 \
          --managed

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region $AWS_REGION --name laredo-cluster
        kubectl get nodes
        kubectl get pods -A

  deploy-k8s-resources:
    name: Deploy Kubernetes Resources
    runs-on: ubuntu-latest
    needs: setup-eks-cluster

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Validate Kubernetes manifests
      run: |
        kubectl apply --dry-run=client --validate=true -f Deploy/nginx-deploy.yml
        kubectl apply --dry-run=client --validate=true -f Deploy/nginx-service.yml
        kubectl apply --dry-run=client --validate=true -f Deploy/prom-deploy.yml
        kubectl apply --dry-run=client --validate=true -f Deploy/prom-service.yml
        kubectl apply --dry-run=client --validate=true -f Deploy/node-exporter-deploy.yml
        kubectl apply --dry-run=client --validate=true -f Deploy/node-exporter-svc.yml

    - name: Apply Nginx Deployment and Service
      run: |
        kubectl apply -f Deploy/nginx-deploy.yml
        kubectl apply -f Deploy/nginx-service.yml

    - name: Apply Prometheus Deployment and Service
      run: |
        kubectl apply -f Deploy/prom-deploy.yml
        kubectl apply -f Deploy/prom-service.yml

    - name: Apply Node Exporter DaemonSet and Service
      run: |
        kubectl apply -f Deploy/node-exporter-deploy.yml
        kubectl apply -f Deploy/node-exporter-svc.yml

    - name: Wait for resources to be ready
      run: |
        kubectl wait --for=condition=ready pod -l app=nginx --timeout=300s
        kubectl wait --for=condition=ready pod -l app=prometheus --timeout=300s
        kubectl wait --for=condition=ready pod -l app=node-exporter --timeout=300s
        kubectl get all -A

# Notes on the Scripts:

This GitHub Actions pipeline does **not** require storing the `kubeconfig` file as a secret in GitHub. 

### **How the Pipeline Handles Kubeconfig**

1. **Dynamic generation**

- The pipeline dynamically generates the `kubeconfig` file during runtime using the `aws eks update-kubeconfig` command, which configures the kubeconfig file for cluster access based on the EKS cluster name and AWS region. This updates the local kubeconfig file and automatically stores it in `/home/runner/.kube/config` on the GitHub Actions runner. This method ensures the kubeconfig file is always up-to-date and reflects the current cluster configuration.Hence, there is no need to pre-store it as a GitHub secret since the kubeconfig file is generated and stored temporarily.  

2. **Security**:

   - There is increased security for the pipeline workflow because of the reduction of the risk of exposure  of sensitive information associated with the cluster arising from the dynamic generation of the kubeconfig file on the runner instead of storing it as a GitHub secret.
   
3. **Ephemeral Nature**:

   - The kubeconfig file created during pipeline execution only susbsist as long as the pipeline as it only exists during the job’s runtime. 

### **Configure Kubeconfig file as as a GitHub Secret**

There are situations where the need to store the kubeconfig file as a GitHub secret arises:
  
- When there is the need for persistent cluster access outside of the pipeline’s runtime.
- When the cluster doesn’t support dynamic kubeconfig generation with `aws eks update-kubeconfig`.


