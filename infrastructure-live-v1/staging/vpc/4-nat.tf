resource "aws_eip" "nat" {
  tags = {
    Name = "staging-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_eu_central_1a.id

  tags = {
    Name = "staging-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
