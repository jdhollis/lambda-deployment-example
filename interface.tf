variable "region" {
  type        = "string"
  description = "AWS region"
  default     = "us-east-1"
}

variable "function_name" {
  type    = "string"
  default = "lambda-deployment-example"
}
