resource "aws_vpc" "main" {
  cidr_block       = var.vpc-cidr-block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "pralay-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  count = length(var.public-subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public-subnet, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "pralay-public-subnet${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pralay-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pralay-public-rt"
  }
}

resource "aws_route_table_association" "public-asso" {
  count = length(var.public-subnet)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_subnet" "private-subnet" {
  count = length(var.private-subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private-subnet, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "pralay-private-subnet${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "pralay-ngw"
  }
  depends_on = [aws_eip.eip]
}

resource "aws_route_table" "private-rt" {
  count = length(var.private-subnet)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "pralay-private-rt${count.index}"
  }
}

resource "aws_route_table_association" "private-asso" {
  count = length(var.private-subnet)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt[count.index].id
}

