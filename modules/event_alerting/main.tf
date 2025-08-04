variable "environment" {
  description = "Deployment environment"
  type        = string
}

resource "aws_sns_topic" "critical_feedback" {
  name = "critical-feedback-${var.environment}"
}

resource "aws_sns_topic_subscription" "alert_lambda" {
  topic_arn = aws_sns_topic.critical_feedback.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to notify"
  type        = string
}

output "sns_topic_arn" {
  value = aws_sns_topic.critical_feedback.arn
}
