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


