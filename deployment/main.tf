terraform {
  backend "s3" {
    bucket  = ""                                                   # Partial configuration
    key     = "lambda/lambda-deployment-example/terraform.tfstate" # Alas, no variable interpolation in the backend config
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  current = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "function_permissions" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*",
    ]
  }

  # Add function-specific permissions here
}

resource "aws_iam_role" "function_role" {
  name               = "${var.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "lambda_deployment_example" {
  name   = "${var.function_name}"
  policy = "${data.aws_iam_policy_document.function_permissions.json}"
  role   = "${aws_iam_role.function_role.name}"
}

resource "aws_lambda_function" "definition" {
  s3_bucket        = "${var.build_artifacts_bucket}"
  s3_key           = "lambda/deployed/${var.function_jar}"
  source_code_hash = "${base64sha256(file(var.function_jar))}"
  function_name    = "${var.function_name}"
  handler          = "${var.function_handler}"
  role             = "${aws_iam_role.function_role.arn}"
  memory_size      = 256
  runtime          = "java8"
  timeout          = 30
  publish          = true

  # Add function-specific environment variables here
}
