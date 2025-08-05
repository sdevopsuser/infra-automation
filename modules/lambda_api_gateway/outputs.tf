output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.api_handler.arn
}
output "api_endpoint" {
  description = "The endpoint URL of the deployed API Gateway."
  value       = aws_apigatewayv2_api.feedback_api.api_endpoint
}
output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api_handler.function_name
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.feedback_api.id
}

output "analytics_summary_lambda_function_name" {
  description = "Analytics summary Lambda function name"
  value       = aws_lambda_function.analytics_summary.function_name
}

output "analytics_summary_lambda_function_arn" {
  description = "Analytics summary Lambda function ARN"
  value       = aws_lambda_function.analytics_summary.arn
}