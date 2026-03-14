terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FreshDirect"
      Environment = "production"
      ManagedBy   = "terraform"
      Course      = "IT473"
      Team        = "Alex Moise / Mehak Saeed / Chris Thomas / Tyler Kizer"
    }
  }
}
