---
title: S3 실습코드
weight: 53
pre: "<b>5-3. </b>"
---

### s3/provider.tf
```bash
provider "aws" {
  region = "ap-northeast-2"
}
```

### s3/backed.tf
```bash
terraform {
  backend "s3" {
      bucket         = "tf101-jupiter-apne2-tfstate" 
      key            = "terraform101/s3/terraform.tfstate"
      region         = "ap-northeast-2"
      encrypt        = true
      dynamodb_table = "terraform-lock" 
  }
}
```

### s3/s3.tf
```bash
resource "aws_s3_bucket" "s3" {
  bucket = "devopsart-terraform-101"
}
```
