provider "terraform" {
  version = "~> 0.1"
}

terraform {
  backend "s3" {
    bucket         = ""
    key            = "lambda/lambda-deployment-example/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = ""
    profile        = ""
    encrypt        = true
    kms_key_id     = ""
  }
}

provider "aws" {
  version = "~> 0.1"
  region  = "${var.region}"
  profile = "givewith"
}

module "pipeline" {
  source = "./pipeline"
}
