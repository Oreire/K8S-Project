# K8S-Project
# Created Kube-Cluster-policy, CloudFormation-policies && EC2-DESCRIBE-VPC (IAM)
# Updates to the localhost K8S cluster
GitHub Actions Pipeline

# 🚀 Kubernetes on AWS (EKS) with CI/CD - TechBleat Project

This project is a hands-on implementation of the automation of the provisioning and deployment of a Kubernetes cluster and its associated resources using  **Terraform**, **GitHub Actions**, and **AWS EKS**. A structured approach was utilized for the infrastructure provisioning and services deployment in line with DevOps best practices.

---

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
   - Configure kubectl on EC2
   - Deploy Kubernetes resources via manifest files

---

## 🧱 Infrastructure Diagram

The architecture includes:
- **VPC (192.168.0.0/16)** with public & private subnets across 2 AZs (eu-west-2a & eu-west-2b)
- **NGINX services in public subnets** behind an Application Load Balancer
- **Monitoring stack (Prometheus + Node Exporter)** in private subnets
- EC2 instances used as Jenkins agents and to manage deployments

## 🛠️ Jenkins Pipeline Overview

The `Jenkinsfile` is split into stages:

1. **Terraform Init/Plan/Apply**
2. **Configure kubectl access on remote EC2**
3. **Install kubectl CLI if not present**
4. **Apply Kubernetes manifests for all services**

Environment variables and credentials (e.g., `AWS_ACCESS_KEY_ID`, `KUBECONFIG`, `SSH_PRIVATE_KEY`) are securely injected via Jenkins credentials store.

---

## 🚀 Deployment Steps

### ✅ Prerequisites

- AWS Account with access credentials
- Jenkins Server with required plugins
- Terraform CLI
- EC2 instance with SSH access for kubectl config

### 🔨 Steps

1. **Clone the repository**
2. **Configure Jenkins credentials** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `SSH_PRIVATE_KEY`, `KUBECONFIG-FILE`)
3. **Trigger Jenkins pipeline**
4. **Verify deployment via `kubectl get all`**

---

## 📦 Kubernetes Resources Deployed

| Component           | Type         | Service Type     |
|---------------------|--------------|------------------|
| NGINX               | Deployment   | LoadBalancer     |
| Prometheus          | Deployment   | LoadBalancer     |
| Node Exporter       | DaemonSet    | ClusterIP        |


DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
Here’s a technical overview of the document detailing the **K8S Project**:

---

### **1. Repository Overview**:
- The project’s repository is located at: [GitHub - Oreire/K8S-Project](https://github.com/Oreire/K8S-Project.git).
- The document outlines the workflows, configurations, and deployment methodologies used to build and manage Kubernetes resources in the cluster.

---

### **2. Terraform Provisioning**:
- **Purpose**: Automating the infrastructure setup.
- **Terraform Pipeline**:
  - Provisioned a Virtual Private Cloud (VPC) along with associated components like subnets and internet gateway.
  - Successfully established a 3-node EKS (Elastic Kubernetes Service) cluster and supporting CloudFormation stacks.
  - Outputs included private and public subnet details as well as VPC (cluster-net) identifiers.
  - The plan applied configuration to add resources, such as `public_subnet`, `private_subnet`, and `vpc_id`.

---

### **3. Kubernetes Cluster and Resources**:
- **Cluster Details**:
  - Named `Pro8-cluster`.
  - Comprises 3 nodes, provisioned using CloudFormation templates managed by `eksctl`.
  - IAM roles and policies were appropriately configured for cluster access.

- **Node Groups**:
  - Auto-scaling group provisioned with a desired capacity of 3 nodes (minimum 3, maximum 5).
  - Nodes deployed to two availability zones (`eu-west-2`).

---

### **4. Kubernetes Resource Deployment**:
- **Challenges**:
  - Automation of deployments and services via GitHub Actions encountered issues and was ultimately handled manually.
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


### **5. Testing and Observations**:
- **Availability and Scalability**:
  - Deployment resources were tested to validate fault tolerance.
- **Provisioned Services**:
  - Services mapped to external endpoints for browser access, utilizing AWS Elastic Load Balancer DNS.


### **6. IAM Policies**:
- Attached IAM policies included:
  - Amazon-managed policies for EC2, EKS, and VPC access.
  - Inline custom policies for cluster-specific requirements.



### **7. Challenges Highlighted**:
- GitHub Actions pipeline failed to automate deployments and services due to OpenAPI connection issues and validation failures.
