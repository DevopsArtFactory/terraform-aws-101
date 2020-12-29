---
title: (Optional)실습용 EC2 기본 설정
weight: 60
---

## 실습에 필요한 EC2 인스턴스 생성
본 실습은 EC2 인스턴스를 생성해서 진행합니다. 그런데 이렇게 실습을 위한 EC2 생성 또한 Terraform으로 생성하실 수 있습니다.

본 작업은 이전 실습이 전부 진행되었다는 전제 하에 진행합니다.

*단, 본 작업은 반드시 로컬에서 진행해주셔야 합니다.*

### 참조 코드
코드는 아래 링크를 참조하셔서 생성하시면 됩니다. 앞선 Chapter 실습을 진행하셨으면 어렵지 않게 이해하실 수 있습니다.

https://github.com/DevopsArtFactory/aws-provisioning/tree/main/terraform/ec2/art-id

### 고쳐야할 부분
backend.tf
```
terraform {
  required_version = "= 0.12.24"

  backend "s3" {
    bucket         = "art-id-apnortheast2-tfstate" # 자신의 버킷으로 수정
    key            = "art/terraform/ec2/art-id/artd_apnortheast2/terraform.tfstate" # 원하는 키 사용
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock" # 앞에서 생성한 DynamoDB 이름
  }
}
```

ec2.tf
```
module "ec2" {
  source = "../_module/ec2"

  service_name              = "ec2-machine" # 서비스 이름 변경
  base_ami                  = "ami-0db78afd3d150fc18" # AMI 선택
  instance_type             = "t3.small" #원하는 사이즈 선택
  instance_profile          = ""

  # VPC는 앞에서 이미 만들어져 있어야 합니다.
  vpc_name                  = data.terraform_remote_state.vpc.outputs.vpc_name
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets
  target_vpc                = data.terraform_remote_state.vpc.outputs.vpc_id
  shard_id                  = data.terraform_remote_state.vpc.outputs.shard_id

  route53_internal_domain   = data.terraform_remote_state.vpc.outputs.route53_internal_domain
  route53_internal_zone_id  = data.terraform_remote_state.vpc.outputs.route53_internal_zone_id
  internal_domain_name      = "art.internal"

  stack                     = "artd_apnortheast2"
  ebs_optimized             = false

  key_name                  = "art-id-main"

  ext_lb_ingress_cidrs = [
    "x.x.x.x/32" # 본인의 IP
  ]

  lb_variables = var.lb_variables
  sg_variables = var.sg_variables
}
```

remote_state.tf
```
data "terraform_remote_state" "vpc" {
  backend = "s3"

  # remote_state.vpc key 변경
  config = merge(var.remote_state.vpc.artdapne2, {"role_arn"=var.assume_role_arn} ) 
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  # remote_state.iam key 변경
  config = merge(var.remote_state.iam.id, {"role_arn"=var.assume_role_arn} )
}
```

### Terraform init
```
❯ terrafrom init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.30.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Terraform plan
```
❯ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.vpc: Refreshing state...
data.terraform_remote_state.iam: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.ec2.aws_instance.public_ec2 will be created
  + resource "aws_instance" "public_ec2" {
      + ami                          = "ami-0db78afd3d150fc18"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + ebs_optimized                = false
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t3.small"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "art-id-main"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = "subnet-06b12728ace528020"
      + tags                         = {
          + "Name"  = "ec2-machine-artd_apnortheast2"
          + "app"   = "ec2-machine"
          + "stack" = "artd_apnortheast2"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 10
          + volume_type           = (known after apply)
        }
    }

  # module.ec2.aws_security_group.ec2 will be created
  + resource "aws_security_group" "ec2" {
      + arn                    = (known after apply)
      + description            = "ec2-machine Instance Security Group"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Internal outbound traffic"
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Internal outbound traffic"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "10.0.0.0/8",
                ]
              + description      = "Internal outbound traffic"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "x.x.x.x/32",
                ]
              + description      = "SSH port"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "ec2-machine-artd_apnortheast2"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = "vpc-05be14885b028018d"
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

### Terraform apply 진행 
- Plan이 정상적으로 진행되었다면 정상적으로 apply 됩니다. 
❯ terraform apply(생략)


 

