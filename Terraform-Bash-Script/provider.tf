terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA3XF3UXCKK43RZSWQ"
  secret_key = "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"
}