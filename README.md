# K8S-Project
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
            --vpc-id aws_vpc.clust-net.id
            --vpc-private-subnets <prisubnet-1>,<prisubnet-2> 
            --vpc-public-subnets= <pubsubnet-1>,<pubsubnet-2>  
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
