---
title: Base Setup 실습코드
weight: 51
pre: "<b>5-1. </b>"
---


### init/init.tf
```bash
provider "aws" {
  region = "ap-northeast-2" # Please use the default region ID
  version = "~> 2.49.0" # Please choose any version or delete this line if you want the latest version
}

# S3 bucket for backend
resource "aws_s3_bucket" "tfstate" {
  bucket = "tf101-jupiter-apne2-tfstate"

  versioning {
    enabled = true # Prevent from deleting tfstate file
  }
}
```

## Sample 실습 코드

### chapter6/provider.tf
```bash
provider "aws" {
  region = "ap-northeast-2"
}
```

### chapter6/backend.tf
```bash
terraform {
  backend "s3" {
      bucket         = "tf101-jupiter-apne2-tfstate" 
      key            = "terraform101/chapter6/terraform.tfstate"
      region         = "ap-northeast-2"
      encrypt        = true
      dynamodb_table = "terraform-lock" 
  }
}
```

### chapter6/s3.tf
```bash
resource "aws_s3_bucket" "test" {
  bucket = "terraform101-inflearn"
}
```
