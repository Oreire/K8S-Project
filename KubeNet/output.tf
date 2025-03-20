output "vpc_id" {
    description = "The VPC ID"
    value       = aws_vpc.clust-net.id
}

output "public_subnet_1" {
    description = "The ID for public subnet 1"
    value       = aws_subnet.public-1.id
}

output "public_subnet_2" {
    description = "The ID for public subnet 2"
    value       = aws_subnet.public-2.id
}

output "private_subnet_1" {
    description = "The ID for private subnet-1"
    value       = aws_subnet.private-1.id
}

output "private_subnet_2" {
    description = "The ID for private subnet 2"
    value       = aws_subnet.private-2.id
}