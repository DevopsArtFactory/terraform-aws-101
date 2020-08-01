provider "aws" {
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "main" {
  bucket = "devopsart-terraform-101"

  tags = {
    Name        = "devopsart-terraform-101"
  }
}
