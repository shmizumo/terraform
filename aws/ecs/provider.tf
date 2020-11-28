provider "aws" {
  region     = "ap-northeast-1"
  profile    = "mizu0_sandbox"
}

terraform {
  required_version = ">= 0.13.5"

  backend "s3" {
    bucket  = "mizu0-sandbox-tfstate"
    key     = "ecs/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "mizu0_sandbox"
    encrypt = true
  }
}