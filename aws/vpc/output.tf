output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets" {
  value = [for s in aws_subnet.public: s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private: s.id]
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}