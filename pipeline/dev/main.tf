provider "aws" {
  region  = "${var.region}"
  profile = ""

  assume_role {
    role_arn = "${var.assume_role_arn}"
  }
}

module "deployer" {
  source = "../deployer"

  function_name = "${var.function_name}"
  pipeline_name = "${var.function_name}-pipeline"

  lambda_build_artifacts_bucket  = "${var.lambda_build_artifacts_bucket}"
  lambda_build_artifacts_key_arn = "${var.lambda_build_artifacts_key_arn}"
  remote_state_bucket            = "${var.remote_state_bucket}"
  remote_state_bucket_arn        = "${var.remote_state_bucket_arn}"
  remote_state_kms_key_arn       = "${var.remote_state_kms_key_arn}"
  remote_state_locking_table_arn = "${var.remote_state_locking_table_arn}"
  remote_state_region            = "${var.remote_state_region}"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.function_name}-pipeline"
  role_arn = "${var.codepipeline_service_role_arn}"

  artifact_store {
    location = "${var.lambda_build_artifacts_bucket}"
    type     = "S3"

    encryption_key {
      id   = "${var.lambda_build_artifacts_key_arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      name     = "Source"
      owner    = "ThirdParty"
      provider = "GitHub"
      version  = "1"

      output_artifacts = ["lambda-src"]

      configuration {
        OAuthToken = "${var.source_github_token}"
        Owner      = "${var.source_owner}"
        Repo       = "${var.source_repo}"
        Branch     = "${var.source_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      name     = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["lambda-src"]
      output_artifacts = ["lambda-package"]

      configuration {
        ProjectName = "${var.lambda_builder_project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Build"
      name     = "Deploy"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["lambda-package"]

      configuration {
        ProjectName = "${module.deployer.project_name}"
      }
    }
  }

  stage {
    name = "Promote"

    action {
      category = "Invoke"
      name     = "Promote"
      owner    = "AWS"
      provider = "Lambda"
      version  = "1"

      input_artifacts = ["lambda-package"]

      configuration {
        FunctionName   = "lambda-package-promoter"
        UserParameters = "lambda/promoted/${var.function_name}.zip"
      }
    }
  }
}
