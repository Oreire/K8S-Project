# K8S-Project
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
