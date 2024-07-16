data "aws_caller_identity" "current" {}

terraform {
  required_version = "1.9.2"
  backend "s3" {
    bucket = "line-nandemo-tfstate"
    key    = "poc.terraform.tfstate"
    region = "ap-northeast-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
