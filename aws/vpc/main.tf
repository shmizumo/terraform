resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_subnet" "public" {
  for_each          = var.subnet_numbers

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value*2 - 1)
  availability_zone = each.key
  tags = {
    Name = "public-${each.key}"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_subnet" "private" {
  for_each          = var.subnet_numbers
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value*2)
  availability_zone = each.key
  tags = {
    Name = "private-${each.key}"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route-table"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each          = var.subnet_numbers

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_route" "gw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on             = [aws_route_table.public]
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}
resource "aws_nat_gateway" "private" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[keys(var.subnet_numbers)[0]].id

  tags = {
    Name = "main"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private.id
  }

  tags = {
    Name = "private-route-table"
    Terraform = "mizu0/terraform"
  }
}

resource "aws_route_table_association" "private" {
  for_each          = var.subnet_numbers

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[each.key].id
}