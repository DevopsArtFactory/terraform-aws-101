---
title: IAM 실습코드
weight: 54
pre: "<b>5-4. </b>"
---

### iam/backend.tf
```bash
terraform {
  backend "s3" {
      bucket         = "tf101-jupiter-apne2-tfstate" 
      key            = "terraform101/iam/terraform.tfstate"
      region         = "ap-northeast-2"
      encrypt        = true
      dynamodb_table = "terraform-lock" 
  }
}
```

### iam/provider.tf
```bash
provider "aws" {
  region = var.aws_region
#  region = "ap-northeast-2"
}
```

### iam/devops_group.tf
```bash
resource "aws_iam_group" "devops_group" {
  name = "devops"

}

resource "aws_iam_group_membership" "devops" {
  name = aws_iam_group.devops_group.name

  users = var.user_list

  group = aws_iam_group.devops_group.name
}
```

### iam/iam_role_hello.tf
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
        "s3:*"
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

### iam/terraform.tfvars
```bash
aws_region="us-east-1"
```


### iam/user_gildong_hong.tf
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

### iam/user_juyoung_song.tf
```bash
resource "aws_iam_user" "juyoung_song" {
  name = "juyoung.song"
}

resource "aws_iam_user_policy" "art_devops_black_juyoung" {
  name  = "super-admin"
  user  = aws_iam_user.juyoung_song.name

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

### iam/variables.tf
```bash
variable "aws_region" {
  description = "This is region for AWS."
  default     = ""
}

variable "user_list" {
  type    = list(string)
  default = ["juyoung.song","gildong.hong"]
}
```
