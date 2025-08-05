variable "analytics_lambda_package" {
  description = "Path to the analytics summary Lambda deployment package"
  type        = string
}

variable "analytics_lambda_handler" {
  description = "Handler for the analytics summary Lambda"
  type        = string
  default     = "analytics_summary.lambda_handler"
}
