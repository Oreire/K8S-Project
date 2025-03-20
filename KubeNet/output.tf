output "vpc_id" {
    description = "The VPC ID"
    value       = aws_vpc.cluster-net.id
}

output "public_subnet_1" {
    description = "The ID for public subnet 1"
    value       = aws_subnet.pubsub-1.id
}

output "public_subnet_2" {
    description = "The ID for public subnet 2"
    value       = aws_subnet.pubsub-2.id
}

output "private_subnet_1" {
    description = "The ID for private subnet-1"
    value       = aws_subnet.prisub-1.id
}

output "private_subnet_2" {
    description = "The ID for private subnet 2"
    value       = aws_subnet.privsub-2.id
}
