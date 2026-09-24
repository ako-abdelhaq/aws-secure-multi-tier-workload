# Public Route Table (Internet Access)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_prefix}-public-rt"
    Tier = "Public"
  }
}

# Associate Web Subnets with Public Route Table
resource "aws_route_table_association" "public_web_a" {
  subnet_id      = aws_subnet.public_web_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_web_b" {
  subnet_id      = aws_subnet.public_web_b.id
  route_table_id = aws_route_table.public.id
}


# Private Route Table (Isolated / Internal Only)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # No explicit routes defined here.
  # AWS automatically creates the local route (10.0.0.0/16 -> local).

  tags = {
    Name = "${var.project_prefix}-private-rt"
    Tier = "Private"
  }
}

# Associate App Subnet with Private Route Table
resource "aws_route_table_association" "private_app" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private.id
}

# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "private_db_a" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_b" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private.id
}
