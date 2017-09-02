data "aws_region" "current" {
  current = true
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_codebuild_service_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "deployer" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.function_name}-deployer",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.function_name}-deployer:*",
    ]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${var.remote_state_bucket_arn}"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${var.remote_state_bucket_arn}/lambda/${var.function_name}/terraform.tfstate"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = ["arn:aws:s3:::${var.lambda_build_artifacts_bucket}/${substr(var.pipeline_name, 0, 19)}/*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::${var.lambda_build_artifacts_bucket}/lambda/deployed/${var.function_name}.jar"]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]

    resources = ["${var.remote_state_locking_table_arn}"]
  }

  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.function_name}"]
  }

  statement {
    actions = [
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:CreateEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:GetPolicy",
      "lambda:ListVersionsByFunction",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:UpdateAlias",
      "lambda:UpdateEventSourceMapping",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}*",
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-source-mappings:*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeRegions",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "deployer" {
  name               = "${var.function_name}-deployer"
  assume_role_policy = "${data.aws_iam_policy_document.assume_codebuild_service_role.json}"
}

resource "aws_iam_role_policy" "deployer" {
  name   = "${var.function_name}-deployer"
  role   = "${aws_iam_role.deployer.id}"
  policy = "${data.aws_iam_policy_document.deployer.json}"
}

resource "aws_codebuild_project" "deployer" {
  name = "${var.function_name}-deployer"

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image        = "aws/codebuild/eb-java-8-amazonlinux-64:2.4.3"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "TERRAFORM_STATE_BUCKET"
      value = "${var.remote_state_bucket}"
    }

    environment_variable {
      name  = "TERRAFORM_STATE_LOCK_TABLE"
      value = "${element(split("/", var.remote_state_locking_table_arn), 1)}"
    }

    environment_variable {
      name  = "TERRAFORM_STATE_REGION"
      value = "${var.remote_state_region}"
    }

    environment_variable {
      name  = "TERRAFORM_STATE_KMS_KEY_ARN"
      value = "${var.remote_state_kms_key_arn}"
    }

    environment_variable {
      name  = "REGION"
      value = "${data.aws_region.current.name}"
    }

    environment_variable {
      name  = "BUILD_ARTIFACTS_BUCKET"
      value = "${var.lambda_build_artifacts_bucket}"
    }

    environment_variable {
      name  = "BUILD_ARTIFACTS_KMS_KEY_ARN"
      value = "${var.lambda_build_artifacts_key_arn}"
    }

    environment_variable {
      name  = "FUNCTION_NAME"
      value = "${var.function_name}"
    }

    environment_variable {
      name  = "FUNCTION_ARN"
      value = "${var.function_arn}"
    }

    environment_variable {
      name  = "FUNCTION_JAR"
      value = "${var.function_jar}"
    }

    # Add function-specific environment variables here
  }

  service_role  = "${aws_iam_role.deployer.arn}"
  build_timeout = "5"                            # minutes
}
