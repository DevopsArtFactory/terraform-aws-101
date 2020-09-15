---
title: Variables 활용하기
weight: 42
pre: "<b>4-2. </b>"
---

### Terraform variables 사용하기
Terraform 은 HCL Syntax를 가진 언어입니다.
언어적 특성을 가지고 있기 때문에 당연히 변수를 정의하고 주입해서 사용할 수 있습니다.


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

#### 변수를 정의하기 variables.tf
변수의 정의는 .tf 파일 어느 곳에서나 정의는 가능합니다.
보통 variables.tf 파일을 만들어 해당 파일에 정의합니다.

```bash
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "ami_id_maps" {
  type = map
  default = {}
}
```

#### terraform.tfvars
정의한 변수에 값을 주입하기 위해 가장 일반적인 방법은 terraform.tfvars 파일을 생성하는 것입니다.
**Variable = Value** 형태로 정의합니다.

```bash
image_id = "ami-064c81ce3a290fde1"
availability_zone_names = ["us-west-1a","us-west-1b","us-west-1c"]
ami_id_maps = {
    ap-northeast-2 = {
      amazon_linux2 = "ami-010bf43fe22f847ed"
      ubuntu_18_04  = "ami-061b0ee20654981ab"
    }

    us-east-1 = {
      amazon_linux2 = "ami-0d29b48622869dfd9"
      ubuntu_18_04  = "ami-0d324124b7b7eec66"
    }
}
```
{{% notice info %}}
terraform.tfvars 가 아닌 다른 방법으로는 module block 에 주입하는 방법이 있습니다.
{{% /notice %}}