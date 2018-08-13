resource "aws_iam_user" "terraboard" {
  name = "terraboard-demo"
  path = "/services/"
}

resource "aws_iam_access_key" "terraboard" {
  user = "${aws_iam_user.terraboard.name}"
}

data "aws_iam_policy_document" "terraboard" {
  statement {
    sid = "ReadOnly"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetObjectVersion",
    ]

    resources = [
      "${data.aws_s3_bucket.terraform-state.arn}/*",
      "${data.aws_s3_bucket.terraform-state.arn}",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.terraboard.arn}"]
    }
  }
}

resource "aws_iam_user_policy" "terraboard-dynamodb" {
  name = "terraboard-dynamodb"
  user = "${aws_iam_user.terraboard.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnly",
      "Action": [
        "dynamodb:Scan"
      ],
      "Effect": "Allow",
      "Resource": "${data.aws_dynamodb_table.terraform_statelock.arn}"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "terraboard" {
  bucket = "${data.aws_s3_bucket.terraform-state.bucket}"
  policy = "${data.aws_iam_policy_document.terraboard.json}"
}

resource "docker_image" "postgres" {
  name = "postgres:9.5"
}

resource "docker_container" "terraboard-postgres" {
  name = "terraboard-postgres"
  image = "${docker_image.postgres.latest}"
  env = [
    "POSTGRES_USER=tb",
    "POSTGRES_PASSWORD=mypass",
    "POSTGRES_DB=terraboard"
  ]
}

resource "docker_image" "terraboard" {
  name = "camptocamp/terraboard:0.14.0"
}

resource "docker_container" "terraboard" {
  name = "terraboard"
  image = "${docker_image.terraboard.latest}"
  ports {
    internal = "8080"
    external = "8080"
  }
  env = [
    "AWS_REGION=${data.aws_s3_bucket.terraform-state.region}",
    "AWS_ACCESS_KEY_ID=${aws_iam_access_key.terraboard.id}",
    "AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.terraboard.secret}",
    "AWS_BUCKET=${data.aws_s3_bucket.terraform-state.bucket}",
    "AWS_DYNAMODB_TABLE=${data.aws_dynamodb_table.terraform_statelock.name}",
    "DB_USER=tb",
    "DB_PASSWORD=mypass",
    "DB_NAME=terraboard",
    "DB_HOST=${docker_container.terraboard-postgres.ip_address}",
    "AWS_FILE_EXTENSION=_state"
  ]
  restart = "always"
}
