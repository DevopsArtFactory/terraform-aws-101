---
title: Variables 활용하기
weight: 42
pre: "<b>4-2. </b>"
---

### Terraform variables 사용하기
Terraform 을 프로그래밍 언어라 볼 수 는 없지만, 그래도 언어적 특성과 장점을 가지고 있습니다.
그렇기 때문에 언어의 variables 를 사용할 수 있습니다.

#### Variable Types
- string
- number
- bool

#### Complex variable types
- list(<TYPE>)
- set(<TYPE>)
- map(<TYPE>)
- object({<ATTR NAME> = <TYPE>, ... })
- tuple([<TYPE>, ...])

[Terraform Variables](https://www.terraform.io/docs/configuration/variables.html) 을 참고하세요!

#### example

```bash
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}
```