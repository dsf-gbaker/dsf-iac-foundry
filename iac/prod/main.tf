
terraform {

  required_version = "~> 1.1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Name        = var.project-name
      Owner       = var.owner
    }
  }
}