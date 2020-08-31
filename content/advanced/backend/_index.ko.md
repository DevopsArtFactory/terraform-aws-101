---
title: Backend 활용하기
weight: 41
pre: "<b>4-1. </b>"
---


## Terraform Backend 란?

Terraform "[Backend](https://www.terraform.io/docs/backends/index.html)" 는 Terraform의 state file을 어디에 저장을 하고, 가져올지에 대한 설정입니다.
기본적으로는는 로컬 스토리지에 저장을 하지만, 설정에 따라서 s3, consul, etcd 등 다양한 "[Backend type](https://www.terraform.io/docs/backends/types/index.html)"을 사용할 수 있습니다.

## Terraform Backend 를 사용하는 이유?
 
- **Locking**: 보통 Terraform 코드를 혼자 작성하지 않습니다. 
인프라를 변경한다는 것은 굉장히 민감한 작업이 될 수 있습니다. 
원격 저장소를 사용함으로써 동시에 같은 state를 접근하는 것을 막아 의도치 않은 변경을 방지할 수 있습니다.
- **Backup**: 로컬 스토리지에 저장한다는건 유실할 수 있다는 가능성을 내포합니다. S3와 같은 원격저장소를 사용함으로써 state 파일의 유실을 방지합니다.


{{% notice tip %}}
Terraform에서 가장 보편적으로 사용하는 s3 backend 를 예제로 합니다.
AWS S3는 쉽게 구축할 수 있으며 versioning 을 지원하는 안전한 저장소입니다.
{{% /notice %}}

```bash
terraform {
    backend "s3" { # 강의는 
      bucket         = "terraform-s3-bucket" # s3 bucket 이름
      key            = "terraform/own-your-path/terraform.tfstate" # s3 내에서 저장되는 경로를 의미합니다.
      region         = "ap-northeast-2"  
      encrypt        = true
      dynamodb_table = "terraform-lock"
    }
}
```

## Terraform Backend 실습

#### S3 bucket as backend
테라폼의 상태를 저장하기 위해 S3 버킷을 생성합니다.
AWS S3는 쉽게 구축할 수 있으며 versioning 을 지원하는 안전한 저장소입니다.

####  DynamoDB Table for Lock
동시에 같은 파일을 수정하지 못하도록 하기 위해 DynamoDB에 작업에 대한 Lock을 생성합니다.

#### 코드생성
Terraform code `init.tf` 파일을 작성합니다.
Terraform Backend 설정을 위한 s3 와 DynamoDB를 생성하는 코드입니다.

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

# DynamoDB for terraform state lock
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

`terraform plan` 명령어 결과입니다.
작성한 `init.tf` 파일로 생성되는 예상 결과를 나타냅니다. 
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

  # aws_dynamodb_table.terraform_state_lock will be created
  + resource "aws_dynamodb_table" "terraform_state_lock" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "terraform-lock"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # aws_s3_bucket.tfstate will be created
  + resource "aws_s3_bucket" "tfstate" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "tf101-jupiter-apne2-tfstate"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```

곧이어 `terraform apply` 명령어를 입력합니다.
```bash
$ tf12 apply 

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.terraform_state_lock will be created
  + resource "aws_dynamodb_table" "terraform_state_lock" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "terraform-lock"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # aws_s3_bucket.tfstate will be created
  + resource "aws_s3_bucket" "tfstate" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "tf101-inflearn-apne2-tfstate"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes # 입력받을 수 있는 stdin 출력됩니다.

...생략

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

```

`terraform.tfstate`

```bash
{
  "version": 4,
  "terraform_version": "0.12.24",
  "serial": 3,
  "lineage": "3c77XXXX-2de4-7736-1447-038974a3c187",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_dynamodb_table",
      "name": "terraform_state_lock",
      "provider": "provider.aws",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "arn": "arn:aws:dynamodb:ap-northeast-2:111111111111111111:table/terraform-lock",
            "attribute": [
              {
                "name": "LockID",
                "type": "S"
              }
            ],
            "billing_mode": "PAY_PER_REQUEST",
            "global_secondary_index": [],
            "hash_key": "LockID",
            "id": "inflearn-terraform-lock",
            "local_secondary_index": [],
            "name": "inflearn-terraform-lock",
            "point_in_time_recovery": [
              {
                "enabled": false
              }
            ],
            "range_key": null,
            "read_capacity": 0,
            "server_side_encryption": [],
            "stream_arn": "",
            "stream_enabled": false,
            "stream_label": "",
            "stream_view_type": "",
            "tags": null,
            "timeouts": null,
            "ttl": [
              {
                "attribute_name": "",
                "enabled": false
              }
            ],
            "write_capacity": 0
          },
          "private": "XXXXXXXXiOnsiY3JlYXRlIjo2MDAXXXXXAsImRlbGV0ZSIXX6NjAwMXXXXXXGRhdGUiOjM2MDAwMDAwMDAwMDB9LCJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "tfstate",
      "provider": "provider.aws",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "acceleration_status": "",
            "acl": "private",
            "arn": "arn:aws:s3:::tf101-jupiter-apne2-tfstate",
            "bucket": "tf101-inflearn-apne2-tfstate",
            "bucket_domain_name": "tf101-jupiter-apne2-tfstate.s3.amazonaws.com",
            "bucket_prefix": null,
            "bucket_regional_domain_name": "tf101-jupiter-apne2-tfstate.s3.ap-northeast-2.amazonaws.com",
            "cors_rule": [],
            "force_destroy": false,
            "hosted_zone_id": "Z3W03O7XXXXXXX",
            "id": "tf101-jupiter-apne2-tfstate",
            "lifecycle_rule": [],
            "logging": [],
            "object_lock_configuration": [],
            "policy": null,
            "region": "ap-northeast-2",
            "replication_configuration": [],
            "request_payer": "BucketOwner",
            "server_side_encryption_configuration": [],
            "tags": {},
            "versioning": [
              {
                "enabled": true,
                "mfa_delete": false
              }
            ],
            "website": [],
            "website_domain": null,
            "website_endpoint": null
          },
          "private": "bnVsbA=="
        }
      ]
    }
  ]
}

```