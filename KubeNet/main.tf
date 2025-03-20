provider "aws" {
  region = "eu-west-2"
}

# VPC Definition
resource "aws_vpc" "cluster-net" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "KubeVPC"
  }
}

# Public Subnets
resource "aws_subnet" "pubsub-1" {
  vpc_id = aws_vpc.cluster-net.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"
  tags = {
    Name = "pubsub-1"
  }
}

resource "aws_subnet" "pubsub-2" {
  vpc_id = aws_vpc.cluster-net.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2b"
  tags = {
    Name = "pubsub-2"
  }
}

# Private Subnets
resource "aws_subnet" "privsub-1" {
  vpc_id = aws_vpc.cluster-net.id
  cidr_block = "192.168.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"
  tags = {
    Name = "privsub-1"
  }
}

resource "aws_subnet" "privsub-2" {
  vpc_id = aws_vpc.cluster-net.id
  cidr_block = "192.168.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"
  tags = {
    Name = "privsub-2"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-net.id
  tags = {
    Name = "ClusterIGW"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cluster-net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "pubsub-1" {
  subnet_id = aws_subnet.pubsub-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pubsub-2" {
  subnet_id = aws_subnet.pubsub-2.id
  route_table_id = aws_route_table.public.id
}
