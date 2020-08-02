---
title: Backend 활용하기
weight: 41
pre: "<b>4-1. </b>"
---


## Terraform Backend 란?

Terraform "[Backend](https://www.terraform.io/docs/backends/index.html)" 는 Terraform의 state file을 어디에 저장을 하고, 가져올지에 대한 설정입니다.
기본적으로는는 로컬 스토리지에 저장을 하지만, 설정에 따라서 s3, consul, etcd 등 다양한 "[Backend type](https://www.terraform.io/docs/backends/types/index.html)"을 사용할 수 있습니다.

## Terraform Backend 를 사용하는 이유?
 
- **Locking**: 보통 Terraform 코드를 혼자 작성하지 않습니다. 
인프라를 변경한다는 것은 굉장히 민감한 작업이 될 수 있습니다. 
원격 저장소를 사용함으로써 동시에 같은 state를 접근하는 것을 막아 의도치 않은 변경을 방지할 수 있습니다.
- **Backup**: 로컬 스토리지에 저장한다는건 유실할 수 있다는 가능성을 내포합니다. S3와 같은 원격저장소를 사용함으로써 state 파일의 유실을 방지합니다.


{{% notice tip %}}
Terraform에서 가장 보편적으로 사용하는 s3 backend 를 예제로 합니다.
AWS S3는 쉽게 구축할 수 있으며 versioning 을 지원하는 안전한 저장소입니다.
{{% /notice %}}

```bash
terraform {
    backend "s3" { # 강의는 
      bucket         = "terraform-s3-bucket" # s3 bucket 이름
      key            = "terraform/own-your-path/terraform.tfstate" # s3 내에서 저장되는 경로를 의미합니다.
      region         = "ap-northeast-2"  
      encrypt        = true
      dynamodb_table = "terraform-lock"
    }
}
```

## Terraform Backend 실습

#### S3 bucket as backend
테라폼의 상태를 저장하기 위해 S3 버킷을 생성합니다.
AWS S3는 쉽게 구축할 수 있으며 versioning 을 지원하는 안전한 저장소입니다.

####  DynamoDB Table for Lock
동시에 같은 파일을 수정하지 못하도록 하기 위해 DynamoDB에 작업에 대한 Lock을 생성합니다.

Terraform code init.tf
```bash
provider "aws" {
  region = "ap-northeast-2" # Please use the default region ID
  version = "~> 2.49.0" # Please choose any version or delete this line if you want the latest version
}

# S3 bucket for backend
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.account_id}-apnortheast2-tfstate"

  versioning {
    enabled = true # Prevent from deleting tfstate file
  }
}

# DynamoDB for terraform state lock
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

```