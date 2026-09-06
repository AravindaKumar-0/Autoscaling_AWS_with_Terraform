terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-auto-scaling-state-testign-with-terraform"
    key          = "auto-scaling-aws/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
