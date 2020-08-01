---
title: Route Table 구성하기
weight: 35
pre: "<b>3-2-d. </b>"
---

{{% notice info %}}
확인/생성/삭제는 이전과 동일하게 plan/apply/destroy 명령어를 사용하시면 됩니다. 여기서부터는 필요한 경우가 아니면 실행 부분은 생략하도록 하겠습니다.
{{% /notice %}}

## Route Table 생성

Route Table은 트래픽을 규칙에 맞게 전달해주기 위해 필요한 일종의 테이블입니다. Route table은 여러 서브넷에서 동시에 사용할 수 있으며, 이렇게 연결하는 작업은 Association 이라고 합니다.

Route  Table은 `aws_route_table` 리소스를 생성하시면 되고, 서브넷과 연결하실 때는 `aws_route_table_association` 을 사용하시면 됩니다.

```bash
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
```
