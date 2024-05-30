terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.44.0"
    }
  }

  required_version = ">= 0.10.0"
}

provider "aws" {
  region = var.region
  profile = "goad"
}