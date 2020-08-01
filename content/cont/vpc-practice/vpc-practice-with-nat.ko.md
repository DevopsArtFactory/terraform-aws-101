---
title: Private Subnet 및 NAT 구성
weight: 36
pre: "<b>3-2-e. </b>"
---

{{% notice warning %}}
본 페이지에서 생성하는 리소스 중 Nat Gateway는 비용이 많이 발생하는 서비스입니다. 잠깐 생성하고 지우면 문제되지 않지만, 시간단위로 과금되기 때문에 실습이 끝나시면 반드시 삭제하시기 바랍니다.
{{% /notice %}}

### Private Subnet 구성

Private 서브넷은 Public 서브넷과 다르게 인터넷과 통신이 되지 않는 IP 대역입니다. 즉, 인터넷 게이트웨이와 연결이 되어 있지 않은 곳이라서 외부에서 Private 서브넷으로 접근하는 것은 불가능합니다.

생성하는 방법은 위에서 서브넷 생성했던 방식과 동일합니다. 같은 코드이지만, 인터넷 게이트웨이와 연결되어 있느냐 여부에 따라 속성이 달라진다는 점을 기억하시기 바랍니다!

```bash
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
```

### Nat Gateway 생성

Nat Gateway는 Private 서브넷에서 외부와 통신하기 위해서 필요한 일종의 게이트웨이입니다. 이전에 설명드렸던 것처럼 외부에서 Private 서브넷으로는 접근이 불가능하고, 사실 외부에서 접근하지 말아야하는 서비스는 Private 서브넷에 들어가는 것이 좋습니다. 하지만, Private 서브넷에 있는 서버에서는 외부와 통신해야하는 경우가 발생합니다. 예를 들면, 필요한 패키지를 다운로드 받거나, 써드파티 API를 사용하는 경우에는 반드시 인터넷으로 요청을 보내야 합니다.

이럴 때 필요한 것이 바로 NAT Gateway입니다. Nat Gateway는 반드시 고정 IP(Elastic IP)를 가지고 있어야 하고, private subnet에서 보내는 모든 요청이 외부로 나갈 때는 내부IP가 아닌 고정 IP를 사용합니다.

예를 들어, 고정IP가 13.1.1.1 이라면 외부로 나가는 모든 요청은 13.1.1.1에서 보낸 요청으로 표시됩니다.

```bash
10.0.4.1(내부 IP) → 13.1.1.1(고정 IP) → (외부 IP)
```

따라서, Nat Gateway를 만드실 때는 AWS Elastic IP도 함께 생성하셔야 합니다. Nat Gateway는 Public 서브넷에 위치하지만, 연결은 private 서브넷과 합니다. Public 서브넷에 위치하는 이유는 Nat Gateway 자체는 인터넷과 통신이 되어야 하기 때문입니다. 헷갈릴 수 있으니 잘 확인하시기 바랍니다.

```bash
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

  # Private subnet이 아니라 public subnet을 연결하셔야 합니다.
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
```

생성이 완료되면 Private 서브넷에도 Route Table을 생성하여 연결해줍니다.

```bash
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
```
