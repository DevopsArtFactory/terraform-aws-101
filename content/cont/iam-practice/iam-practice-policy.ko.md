---
title: IAM policy 기본 실습
weight: 40
pre: "<b>3-5-c. </b>"
---


## AWS IAM Policy 의 종류

AWS의 접근하는 해당 권한을 정의하는 개체로 AWS IAM 리소스들과 연결하여 사용할 수 있습니다.
즉 AWS IAM policy 는 user 에 할당 할 수 도, group 에 할당 할 수 있습니다.
IAM policy 는 여러 타입으로 나누어져있습니다.

**AWS Managed policy**: AWS에서 먼저 생성해놓은 Policy set 입니다. 사용자가 권한(Permission)을 변경할 수 없습니다.

**Customer Managed policy**: User 가 직접 생성하는 Policy 로 권한을 직접 상세하게 만들어 관리할 수 있습니다.

## IAM user policy 생성

```bash
resource "aws_iam_user" "gildong_hong" {
  name = "gildong.hong"
}

resource "aws_iam_user_policy" "art_devops_black" {
  name  = "super-admin"
  user  = aws_iam_user.gildong_hong.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
```

Terraform Plan 명령어를 통해 생성되는 리소스 iam_user_policy 를 확인하고 생성합니다.

```bash
  + create

Terraform will perform the following actions:

  # aws_iam_user_policy.art_devops_black will be created
  + resource "aws_iam_user_policy" "art_devops_black" {
      + id     = (known after apply)
      + name   = "super-admin"
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "*",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "*",
                        ]
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + user   = "gildong.hong"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_user_policy.art_devops_black: Creating...
aws_iam_user_policy.art_devops_black: Creation complete after 1s [id=gildong.hong:super-admin]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

{{% notice info %}}
resource "aws_iam_user_policy" "art_devops_black" 을 생성함으로써,
gildong.hong 사용자는 해당권한을 가지게 되었습니다.
참고로 해당 iam 권한은 모든 권한을 갖는 권한입니다.
결국 json 형태인 iam policy 를 적절하게 생성하고 부여를 할 수 있어야 합니다. 
{{% /notice %}}
