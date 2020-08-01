---
title: Subnet 구성하기
weight: 33
pre: "<b>3-2-b. </b>"
---

{{% notice info %}}
확인/생성/삭제는 이전과 동일하게 plan/apply/destroy 명령어를 사용하시면 됩니다. 여기서부터는 필요한 경우가 아니면 실행 부분은 생략하도록 하겠습니다.
{{% /notice %}}

## Subnet 생성하기

위의 실습을 통해서 VPC를 생성해보았습니다. 지금부터는 VPC의 구성요소중 하나인 Subnet을 생성해보도록 하겠습니다. Subnet은 특정 Availability Zone 에 속한 네트워크 그룹으로 VPC 내에서도 나눠진 독립적인 네트워크 구역입니다. 

Subnet을 생성하실 때는 `aws_subnet` 이라는 리소스를 사용하시면 됩니다. 필요한 설정은 해당 서브넷을 연결할 VPC의 ID와 해당 서브넷의 cidr block입니다. 서브넷의 cidr block은 반드시 VPC의 cidr block 내에 속해 있어야 합니다.

```bash
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
```

