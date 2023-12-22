terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0" #constraint version
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

locals {
  default_tags = {
    Environment = "dev"
    Owner       = "pralay"
    Project     = "dev"
    CreatedBy   = "terraform"
  }
}

