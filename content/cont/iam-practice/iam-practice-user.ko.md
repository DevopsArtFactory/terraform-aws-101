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

AWS Console을 통해 IAM user 가 올바르게 생성되었는지 확인합니다.

{{% notice info %}}
위 Terraform 코드를 통해 IAM user 를 생성해주었다고 하더라도, console 을 접속할 수 는 없습니다.
생성한 user의 password 가 설정되어있지 않기 때문입니다.
비밀번호와 MFA는 직접 console을 통해 설정해야합니다.
혹은 AWS CLI 를 통해서 자동화를 진행할 수 도 있습니다.
물론 테라폼을 통해 설정을 할 수 도 있으나, aws_iam_user_login_profile 을 사용해야합니다.
해당 리소스는 AWS와 Terraform 중급 수준의 이해가 있어야 사용이 편합니다.
{{% /notice %}}

