variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "function_name" {
  type    = "string"
  default = "lambda-deployment-example"
}

variable "function_handler" {
  type    = "string"
  default = "lambda_deployment_example.stream_handler"
}

variable "function_jar" {
  type    = "string"
  default = "lambda-deployment-example.jar"
}

variable "build_artifacts_bucket" {
  type        = "string"
  description = "Bucket where the build artifacts are stored"
}

output "function_name" {
  value = "${aws_lambda_function.lambda_deployment_example.function_name}"
}

output "function_arn" {
  value = "${aws_lambda_function.lambda_deployment_example.arn}"
}

output "role_arn" {
  value = "${aws_iam_role.lambda_deployment_example.arn}"
}
