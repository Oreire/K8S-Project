# K8S-Project
# Created Kube-Cluster-policy (IAM)
GitHub Actions Pipeline

name: Deploy Kubernetes Resources

on:
  push:
    branches:
      - main

jobs:
  setup-cluster:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-cli@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-2

      - name: Install eksctl
        run: |
          curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.149.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
          sudo mv /tmp/eksctl /usr/local/bin

      - name: Create EKS cluster
        run: |
          eksctl create cluster 
            --name laredo-cluster 
            --region eu-west-2
            --vpc-id "vpc-08a17b6e2ca297b74"
            --vpc-private-subnets "subnet-02bde47502fb02125", "subnet-0f59c570adae02aea"
            --vpc-public-subnets "subnet-083c61532e8a7d397", "subnet-04555ba84be05c2ba"
            --nodegroup-name my-kube-nodes
            --node-type t2.micro 
            --nodes 3


                             
      - name: Configure kubectl for the cluster
        run: aws eks update-kubeconfig --region eu-west-2 --name laredo-cluster

  deploy-resources:
    needs: setup-cluster
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Apply Nginx Deployment and Service
        run: |
          cd Deploy
          kubectl apply -f nginx-deploy.yml
          kubectl apply -f nginx-service.yml

      - name: Apply Prometheus Deployment and Service
        run: |
          cd Deploy
          kubectl apply -f prom-deploy.yml
          kubectl apply -f prom-service.yml

      - name: Apply Prometheus Node Exporter DaemonSet and Service
        run: |
          cd Deploy
          kubectl apply -f node-exporter-deploy.yml
          kubectl apply -f node-exporter-svc.yml

AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
name: Terraform Infrastructure Provisioning

on:
  push:
    branches:
      - main
  
jobs:
  terraform:
    name: Terraform Provisioning
    runs-on: ubuntu-latest
    #env:
     # AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      #AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      #AWS_REGION: eu-west-2

    steps:
      # Step 1: Checkout the repository
      - name: Checkout Code
        uses: actions/checkout@v3

      # Step 2: Set up Terraform
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.4.6 # Replace with the required Terraform version

      # Step 3: Configure AWS Credentials
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-2

      # Step 4: Cache Terraform Plugins
      - name: Cache Terraform Plugins
        uses: actions/cache@v3
        with:
          path: ~/.terraform.d/plugin-cache
          key: terraform-plugin-cache-${{ runner.os }}-${{ hashFiles('**/*.tf') }}
          restore-keys: |
            terraform-plugin-cache-${{ runner.os }}-

      # Step 5: Initialize Terraform Backend
      - name: Terraform Init
        run: |
          cd KubeNet
          terraform init

      # Step 4: Validate and Plan
      - name: Terraform Validate
        run: |
          cd KubeNet
          terraform validate

      - name: Terraform Plan
        run: |
          cd KubeNet
          terraform plan -out=kubeplan

      # Step 8: Apply Terraform Plan (only on pushes to main)
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: |
          cd KubeNet
          terraform apply -auto-approve kubeplan
