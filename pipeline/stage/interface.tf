variable "region" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
}

variable "function_name" {
  type = "string"
}

variable "function_arn" {
  type = "string"
}

variable "function_jar" {
  type = "string"
}

#
# Deployer
#

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

#
# Pipeline
#

variable "codepipeline_service_role_arn" {
  type = "string"
}

variable "lambda_builder_project_name" {
  type = "string"
}
