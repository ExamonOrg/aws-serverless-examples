terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
  backend "s3" {
    bucket = "examon-terraform-state"
    key    = "examples.serverless.eventbridge.tfstate"
    region = "eu-west-1"
  }
}