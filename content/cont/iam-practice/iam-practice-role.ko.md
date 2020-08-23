---
title: IAM role 기본 실습
weight: 38
pre: "<b>3-5-c. </b>"
---


## IAM role 기본 생성

Terraform을 통해서 IAM role을 생성해보도록 하겠습니다. 
IAM User를 생성할 때는 `aws_iam_user`  리소스를 사용하면되고,  필수적으로 필요한 설정은 `name` 입니다.


```bash
resource "aws_iam_role" "app_hello" {
  name               = "app-hello"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "app_hello_s3" {
  name   = "app-hello-s3-artifact-download"
  role   = aws_iam_role.app_hello.id
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AllowAppArtifactsReadAccess",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF

}


resource "aws_iam_instance_profile" "app_hello" {
  name = "app-hello-profile"
  role = aws_iam_role.app_hello.name
}

resource "aws_iam_role_policy_attachment" "app_hello_attach" {
  role       = aws_iam_role.app_hello.name
  policy_arn = aws_iam_policy.app_universal.arn
}

output "hello_instance_profile" {
  value = aws_iam_instance_profile.app_hello.arn
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
