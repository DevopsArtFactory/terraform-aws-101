---
title: IAM group 기본 실습
weight: 37
pre: "<b>3-5-b. </b>"
---

{{% notice info %}}
확인/생성/삭제는 이전과 동일하게 plan/apply/destroy 명령어를 사용하시면 됩니다. 여기서부터는 필요한 경우가 아니면 실행 부분은 생략하도록 하겠습니다.
{{% /notice %}}

## IAM group 기본 생성

Terraform을 통해서 IAM group을 생성해보도록 하겠습니다. 
IAM User를 생성할 때는 `aws_iam_group`  리소스를 사용하면되고,  필수적으로 필요한 설정은 `name` 입니다.


```bash
provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_iam_group" "devops_group" {
  name = "devops"
}
```

Terraform Plan 명령어를 통해 생성되는 리소스를 확인 및 Apply 합니다. (plan 생략)

```bash
$ terraform apply
aws_iam_user.gildong_hong: Refreshing state... [id=gildong.hong]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.devops_group will be created
  + resource "aws_iam_group" "devops_group" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "devops"
      + path      = "/"
      + unique_id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_group.devops_group: Creating...
aws_iam_group.devops_group: Creation complete after 0s [id=devops]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## 생성한 IAM user 를 IAM group 에 등록

IAM user를 IAM group 에 등록하는 것도 Terraform 으로 진행할 수 있습니다.
실제로 AWS IAM user 를 개발자, 데브옵스, 검증 등 조직의 실제 그룹으로 나누고 등록하고 관리해야 합니다.

Terraform을 통해서 IAM group membership을 생성해보도록 하겠습니다. 
IAM User를 생성할 때는 `aws_iam_group_membership`  리소스를 사용하면됩니다.


```bash
resource "aws_iam_group_membership" "devops" {
  name = aws_iam_group.devops_group.name

  users = [
    aws_iam_user.gildong_hong.name
  ]

  group = aws_iam_group.devops_group.name
}
```

Terraform Plan 명령어를 통해 생성되는 리소스를 확인 및 Apply 합니다. (plan 생략)

```bash
$ terraform apply
aws_iam_user.gildong_hong: Refreshing state... [id=gildong.hong]
aws_iam_group.devops_group: Refreshing state... [id=devops]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group_membership.devops will be created
  + resource "aws_iam_group_membership" "devops" {
      + group = "devops"
      + id    = (known after apply)
      + name  = "devops"
      + users = [
          + "gildong.hong",
        ]
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_group_membership.devops: Creating...
aws_iam_group_membership.devops: Creation complete after 1s [id=devops]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

AWS Console 을 통해 user 와 group 이 올바르게 연결되었는지 확인합니다.

{{% notice info %}}
AWS IAM policy 와 group policy 는 'or' 조건을 따른다고 생각하면 편합니다.
allow permission은 합집합으로 permission을 검사합니다.
{{% /notice %}}
