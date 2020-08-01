provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "terraform-101"
  }
}

resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "101subnet-1"
  }
}


resource "aws_subnet" "second_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "101subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.second_subnet.id
  route_table_id = aws_route_table.route_table.id
}


resource "aws_route" "public_internet_gateway" {
  route_table_id              = aws_route_table.route_table.id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.route_table.id
  destination_ipv6_cidr_block      = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_subnet" "first_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "101subnet-private-1"
  }
}

resource "aws_subnet" "second_private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "101subnet-private-2"
  }
}

resource "aws_eip" "nat_1" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_2" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_1.id

  subnet_id = aws_subnet.first_subnet.id

  tags = {
    Name = "NAT-GW-1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_2.id

  subnet_id = aws_subnet.second_subnet.id

  tags = {
    Name = "NAT-GW-2"
  }
}


resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-private-1"
  }
}

resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-private-2"
  }
}

resource "aws_route_table_association" "route_table_association_private_1" {
  subnet_id      = aws_subnet.first_private_subnet.id
  route_table_id = aws_route_table.route_table_private_1.id
}

resource "aws_route_table_association" "route_table_association_private_2" {
  subnet_id      = aws_subnet.second_private_subnet.id
  route_table_id = aws_route_table.route_table_private_2.id
}

resource "aws_route" "private_nat_1" {
  route_table_id              = aws_route_table.route_table_private_1.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_gateway_1.id
}

resource "aws_route" "private_nat_2" {
  route_table_id              = aws_route_table.route_table_private_2.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_gateway_2.id
}
