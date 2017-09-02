data "aws_region" "current" {
  current = true
}

# Insert any remote state here

module "env" {
  source = "dev"
  region = "${data.aws_region.current.name}"

  assume_role_arn = ""

  function_name = "lambda-deployment-example"
  function_arn  = ""
  function_jar  = "lambda-deployment-example.jar"

  source_github_token = ""
  source_owner        = ""
  source_repo         = ""
  source_branch       = ""

  codepipeline_service_role_arn  = ""
  lambda_build_artifacts_bucket  = ""
  lambda_build_artifacts_key_arn = ""
  lambda_builder_project_name    = ""
  remote_state_bucket            = ""
  remote_state_bucket_arn        = ""
  remote_state_kms_key_arn       = ""
  remote_state_locking_table_arn = ""
  remote_state_region            = ""
}
