provider "aws" {
  profile = "sandbox"
  region = "eu-west-1"
}

data "aws_s3_bucket" "terraform-state" {
  bucket = "terraboard-demo"
}

data "aws_dynamodb_table" "terraform_statelock" {
  name = "demo-terraform-statelock"
}

