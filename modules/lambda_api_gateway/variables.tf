variable "sns_topic_arn" {
  description = "SNS topic ARN for critical feedback alerts"
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
  default     = "python3.9"
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for feedback"
  type        = string
}
variable "api_gateway_description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "API for feedback submission"
}
