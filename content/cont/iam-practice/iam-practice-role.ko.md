---
title: IAM role 기본 실습
weight: 38
pre: "<b>3-5-c. </b>"
---


## EC2를 위한 IAM role 기본 생성

Terraform을 통해서 IAM role을 생성해보도록 하겠습니다. 
IAM role을 생성할 때는 `aws_iam_role`  리소스를 사용하면되고, 필수적으로 필요한 설정은 `name` 입니다.
여기에 `aws_iam_role_policy` 도 만들어 생성한 `aws_iam_role` 와 연결하는 작업도 진행해보겠습니다.

```bash
resource "aws_iam_role" "hello" {
  name               = "hello-iam-role"
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

resource "aws_iam_role_policy" "hello_s3" {
  name   = "hello-s3-download"
  role   = aws_iam_role.hello.id
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

resource "aws_iam_instance_profile" "hello" {
  name = "hello-profile"
  role = aws_iam_role.hello.name
}


```

Terraform 명령어를 통해 생성되는 리소스를 확인하고 생성합니다.
Terraform이 리소스간 연결을 생각하여 3개의 Resource를 의도한대로 잘 생성합니다.
```bash
  + create

Terraform will perform the following actions:

  # aws_iam_instance_profile.hello will be created
  + resource "aws_iam_instance_profile" "hello" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "hello-profile"
      + path        = "/"
      + role        = "hello-iam-role"
      + unique_id   = (known after apply)
    }

  # aws_iam_role.hello will be created
  + resource "aws_iam_role" "hello" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "hello-iam-role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_iam_role_policy.hello_s3 will be created
  + resource "aws_iam_role_policy" "hello_s3" {
      + id     = (known after apply)
      + name   = "hello-s3-download"
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:GetObject",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "*",
                        ]
                      + Sid      = "AllowAppArtifactsReadAccess"
                    },
                ]
            }
        )
      + role   = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_role.hello: Creating...
aws_iam_role.hello: Creation complete after 2s [id=hello-iam-role]
aws_iam_instance_profile.hello: Creating...
aws_iam_role_policy.hello_s3: Creating...
aws_iam_role_policy.hello_s3: Creation complete after 2s [id=hello-iam-role:hello-s3-download]
aws_iam_instance_profile.hello: Creation complete after 3s [id=hello-profile]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

{{% notice info %}}
`aws_iam_instance_profile`은 IAM 역할을 위한 컨테이너로서 인스턴스 시작 시 EC2 인스턴스에 역할 정보를 전달하는 데 사용됩니다.
만약 AWS Management 콘솔을 사용하여 Amazon EC2 역할을 생성하는 경우, 
콘솔이 자동으로 인스턴스 프로파일을 생성하여 해당 역할과 동일한 이름을 부여합니다.
{{% /notice %}}
