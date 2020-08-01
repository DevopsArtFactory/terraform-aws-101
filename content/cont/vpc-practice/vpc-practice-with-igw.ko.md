---
title: Internet Gateway 생성
weight: 34
pre: "<b>3-2-c. </b>"
---

{{% notice info %}}
확인/생성/삭제는 위와 동일한 plan/apply/destroy 명령어를 사용하시면 됩니다. 여기서부터는 필요한 경우가 아니면 실행 부분은 생략하도록 하겠습니다.
{{% /notice %}}


## Internet Gateway 생성

인터넷 게이트웨이는 VPC 내부와 외부 인터넷이 통신하기 위한 게이트웨이 중 하나입니다. 인터넷 게이트웨이가 연결된 서브넷은 흔히 `public 서브넷` 이라고 부릅니다.

```bash
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
```
