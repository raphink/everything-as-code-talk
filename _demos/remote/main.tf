provider "aws" {
  profile = "sandbox"
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform-state" {
  acl = "private"

  bucket = "terraboard-demo"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "demo-terraform-statelock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

