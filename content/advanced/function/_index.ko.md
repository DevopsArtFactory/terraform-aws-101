---
title: Functions 활용하기
weight: 43
pre: "<b>4-2. </b>"
---

### Terraform fuction 사용하기
Terraform 을 프로그래밍 언어라 볼 수 는 없지만, 그래도 언어적 특성과 장점을 가지고 있습니다.
그렇기 때문에 프로그래밍처럼 기본 내장된 다양한 fuction 사용할 수 있습니다.

#### Functions
- Numeric functions
- String functions
- Collection functions
- Encoding functions
- Filesystem functions
- Date and Time functions
- Hash and Crypto functions
- IP Network functions
- Type Conversion Functions

[Terraform Function](https://www.terraform.io/docs/configuration/functions.html) 을 참고하세요!

#### VPC 예시 코드 (https://github.com/DevopsArtFactory/aws-provisioning)
현업에서 사용하는 코드로 Terraform function 의 실제 사용사례를 확인해봅니다.
아래의 vpc.tf 파일은 VPC를 이루는 구성요소를 생성하는 코드입니다. 
코드를 읽어보기전에, count 파라미터에 대해서 알아둘 필요가 있습니다.
기본적으로 모든 리소스가 가지고 있는 count 파라미터를 이용하 반복되는 리소스를 간단하게 생성할 수 있습니다.
count 에 부여한 숫자만큼, 리소스는 반복되어 생성되고 자동으로 테라폼내에서 resource_name[0] 처럼 리스트화 됩니다.


```bash
# VPC
# Whole network cidr will be 10.0.0.0/8 
# A VPC cidr will use the B class with 10.xxx.0.0/16
# You should set cidr advertently because if the number of VPC get larger then the ip range could be in shortage.
resource "aws_vpc" "default" {
  cidr_block           = "10.${var.cidr_numeral}.0.0/16" # Please set this according to your company size
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}


## NAT Gateway 
resource "aws_nat_gateway" "nat" {
  # Count means how many you want to create the same resource
  # This will be generated with array format
  # For example, if the number of availability zone is three, then nat[0], nat[1], nat[2] will be created.
  # If you want to create each resource with independent name, then you have to copy the same code and modify some code
  count = length(var.availability_zones)

  # element is used for select the resource from the array 
  # Usage = element (array, index) => equals array[index]
  allocation_id = element(aws_eip.nat.*.id, count.index)
  
  #Subnet Setting
  # nat[0] will be attached to subnet[0]. Same to all index.
  subnet_id = element(aws_subnet.public.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "NAT-GW${count.index}-${var.vpc_name}"
  }

}

# Elastic IP for NAT Gateway 
resource "aws_eip" "nat" {
  # Count value should be same with that of aws_nat_gateway because all nat will get elastic ip
  count = length(var.availability_zones)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}



#### PUBLIC SUBNETS
# Subnet will use cidr with /20 -> The number of available IP is 4,096  (Including reserved ip from AWS)
resource "aws_subnet" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block              = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/20"
  availability_zone       = element(var.availability_zones, count.index)

  # Public IP will be assigned automatically when the instance is launch in the public subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}-${var.vpc_name}"
  }
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "publicrt-${var.vpc_name}"
  }
}


# Route Table Association for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}




#### PRIVATE SUBNETS
# Subnet will use cidr with /20 -> The number of available IP is 4,096  (Including reserved ip from AWS)
resource "aws_subnet" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/20"
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name               = "private${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# Route Table for private subnets
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "private${count.index}rt-${var.vpc_name}"
    Network = "Private"
  }
}

# Route Table Association for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


# DB PRIVATE SUBNETS
# This subnet is only for the database. 
# For security, it is better to assign ip range for database only. This subnet will not use NAT Gateway
# This is also going to use /20 cidr, which might be too many IPs... Please count it carefully and change the cidr.
resource "aws_subnet" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private_db[count.index]}.0/20"
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name               = "db-private${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}

# Route Table for DB subnets
resource "aws_route_table" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "privatedb${count.index}rt-${var.vpc_name}"
    Network = "Private"
  }
}

# Route Table Association for DB subnets
resource "aws_route_table_association" "private_db" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_db.*.id, count.index)
  route_table_id = element(aws_route_table.private_db.*.id, count.index)
}


```