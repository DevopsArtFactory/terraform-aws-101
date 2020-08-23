---
title: IAM user 기본 실습
weight: 36
pre: "<b>3-5-a. </b>"
---


## IAM user 기본 생성

Terraform을 통해서 IAM user를 생성해보도록 하겠습니다. 
IAM User를 생성할 때는 `aws_iam_user`  리소스를 사용하면되고,  필수적으로 필요한 설정은 `name` 입니다.


```bash
provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_iam_user" "gildong_hong" {
  name = "gildong.hong"
}
```

Terraform Plan 명령어를 통해 생성되는 리소스를 확인합니다.

```bash
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.gildong_hong will be created
  + resource "aws_iam_user" "gildong_hong" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "gildong.hong"
      + path          = "/"
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

Terraform apply 를 통해서 리소스를 생성합니다.

```bash
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_user.gildong_hong will be created
  + resource "aws_iam_user" "gildong_hong" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "gildong.hong"
      + path          = "/"
      + unique_id     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_user.gildong_hong: Creating...
aws_iam_user.gildong_hong: Creation complete after 2s [id=gildong.hong]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```


