data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "mizu0-sandbox-tfstate"
    key     = "vpc/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "mizu0_sandbox"
    encrypt = true
  }
}