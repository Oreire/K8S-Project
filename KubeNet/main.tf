provider "aws" {
  region = "eu-west-2"
}

# VPC Definition
resource "aws_vpc" "clust-net" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "KubeNet"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.clust-net.id
  cidr_block = cidrsubnet(aws_vpc.clust-net.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "pubsubnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.clust-net.id
  cidr_block = cidrsubnet(aws_vpc.clust-net.cidr_block, 8, count.index + 2)
  map_public_ip_on_launch = false
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "prisubnet-${count.index + 1}"
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
  count = 2
  subnet_id = element(aws_subnet.public.*.id, count.index)
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
