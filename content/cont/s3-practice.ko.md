---
title: Amazon S3 실습
weight: 34
pre: "<b>3-4. </b>"
---

## S3 Bucket 생성

AWS Bucket은 객체파일을 담을 수 있는 객체 저장소입니다. Amazon S3의 가장 기본이 되는 리소스인 Bucket을 생성해보겠습니다.

S3 bucket을 생성하실 때는 `aws_s3_bucket` 리소스를 사용하시면 됩니다. 참고로 s3 버킷은 전세계적으로 유일한 이름이어야 하기 때문에 중복된 이름을 사용하시면 리소스 생성이 되지 않습니다. 따라서 예제 코드에서 이름을 반드시 변경하시기 바랍니다.

```bash
provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "main" {
  bucket = "devopsart-terraform-101"

  tags = {
    Name        = "devopsart-terraform-101"
  }
}
```

Terrafrom plan을 통해서 생성되는 리소스를 확인합니다.

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

  # aws_s3_bucket.main will be created
  + resource "aws_s3_bucket" "main" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "devopsart-terraform-101"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name" = "devopsart-terraform-101"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

Terraform apply를 통해 실제 리소스를 생성합니다.

```bash
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.main will be created
  + resource "aws_s3_bucket" "main" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "devopsart-terraform-101"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name" = "devopsart-terraform-101"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.main: Creating...
aws_s3_bucket.main: Creation complete after 3s [id=devopsart-terraform-101]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
