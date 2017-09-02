variable "function_name" {
  type = "string"
}

variable "pipeline_name" {
  type = "string"
}

variable "lambda_build_artifacts_bucket" {
  type = "string"
}

variable "lambda_build_artifacts_key_arn" {
  type = "string"
}

variable "remote_state_bucket" {
  type = "string"
}

variable "remote_state_bucket_arn" {
  type = "string"
}

variable "remote_state_kms_key_arn" {
  type = "string"
}

variable "remote_state_locking_table_arn" {
  type = "string"
}

variable "remote_state_region" {
  type = "string"
}

output "project_name" {
  value = "${aws_codebuild_project.deployer.name}"
}
