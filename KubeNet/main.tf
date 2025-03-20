provider "aws" {
  region = "eu-west-2"
}

# VPC Definition
resource "aws_vpc" "clust-net" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "KubeNet"
  }
}

# Public Subnets
resource "aws_subnet" "public-1" {
  vpc_id = aws_vpc.clust-net.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
  tags = {
    Name = "pubsubnet-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id = aws_vpc.clust-net.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
  tags = {
    Name = "pubsubnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private-1" {
  vpc_id = aws_vpc.clust-net.id
  cidr_block = "192.168.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"
  tags = {
    Name = "prisubnet-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id = aws_vpc.clust-net.id
  cidr_block = "192.168.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"
  tags = {
    Name = "prisubnet-2"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "clust-igw" {
  vpc_id = aws_vpc.clust-net.id
  tags = {
    Name = "ClusterInternetGateway"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.clust-net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.clust-igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}
# Security Groups
# Security Group for Kubernetes Nodes
resource "aws_security_group" "k8s_nodes" {
  vpc_id = aws_vpc.clust-net.id
  name   = "k8s-nodes-sg"

  # Allow all internal traffic between nodes and pods
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = [aws_vpc.clust-net.cidr_block]
  }

  # Allow SSH access from my local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["188.29.111.76/32"] 
  }

  # Allow traffic to Kubernetes API server (port 6443)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KubernetesNodesSecurityGroup"
  }
}

# Security Group for LoadBalancer
resource "aws_security_group" "k8s_loadbalancer" {
  vpc_id = aws_vpc.clust-net.id
  name   = "k8s-loadbalancer-sg"

  # Allow HTTP and HTTPS traffic for LoadBalancer services
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KubernetesLoadBalancerSecurityGroup"
  }
}
