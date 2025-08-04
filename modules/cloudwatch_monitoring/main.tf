variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors-${var.lambda_function_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for Lambda function errors"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}
