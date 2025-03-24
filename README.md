# K8S-Project
# Created Kube-Cluster-policy, CloudFormation-policies && EC2-DESCRIBE-VPC (IAM)
# Updates to the localhost K8S cluster
GitHub Actions Pipeline

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



          AAAAAAAAAAAAAAAAA
          
name: Deploy Kubernetes Resources

on:
  push:
    branches:
      - main

jobs:
  setup-cluster:
    name: Setup EKS Cluster
    runs-on: ubuntu-latest
    timeout-minutes: 30
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: eu-west-2
      
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Cache eksctl Binary
        uses: actions/cache@v3
        with:
          path: /tmp/eksctl
          key: eksctl-cache-${{ runner.os }}
          restore-keys: |
            eksctl-cache-${{ runner.os }}

      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Install eksctl
        run: |
          curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.149.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
          sudo mv /tmp/eksctl /usr/local/bin

      - name: Validate clusterConfig.yml
        run: |
          if [ ! -f clusterConfig.yml ]; then
            echo "clusterConfig.yml not found."
            exit 1
          fi

      - name: Create EKS cluster
        run: |
          set -e
          eksctl create cluster -f clusterConfig.yml

      - name: Cleanup Failed Cluster
        if: failure()
        run: |
          eksctl delete cluster --region=eu-west-2 --name=Pro8-cluster

      - name: Create kubeconfig
        run: |
          echo "${{ secrets.KUBECONFIG_CONTENT }}" > ~/.kube/config
          chmod 600 ~/.kube/config

      - name: Configure kubectl
        run: |
          set -e
          aws eks update-kubeconfig --region eu-west-2 --name Pro8-cluster

      - name: Validate EKS cluster
        run: |
          eksctl get cluster --region $AWS_REGION

  deploy-resources:
    name: Deploy Kubernetes Resources
    needs: setup-cluster
    runs-on: ubuntu-latest
    timeout-minutes: 20
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: eu-west-2

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Validate YAML files
        run: |
          cd Deploy
          for file in nginx-deploy.yml nginx-service.yml prom-deploy.yml prom-service.yml; do
            if [ ! -f $file ]; then
              echo "$file not found."
              exit 1
            fi
          done

      - name: Apply Kubernetes Resources
        run: |
          set -e
          cd Deploy
          kubectl apply -f .

