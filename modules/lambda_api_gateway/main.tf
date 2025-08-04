variable "environment" {}
variable "lambda_package" {}
variable "lambda_role_arn" {}
variable "lambda_memory_size" {}
variable "lambda_timeout" {}

resource "aws_lambda_function" "api_handler" {
  function_name    = "feedback-api-${var.environment}"
  filename         = var.lambda_package
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  role             = var.lambda_role_arn
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  # Ensures Lambda is updated when the deployment package changes
  source_code_hash = filebase64sha256(var.lambda_package)
  environment {
    variables = {
      ENVIRONMENT = var.environment
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_apigatewayv2_api" "feedback_api" {
  name          = "feedback-api-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.feedback_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api_handler.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "feedback_route" {
  api_id    = aws_apigatewayv2_api.feedback_api.id
  route_key = "POST /feedback"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.feedback_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.feedback_api.execution_arn}/*/*"
}


