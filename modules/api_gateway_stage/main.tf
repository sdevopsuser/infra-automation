variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "api_gateway_stage" {
  description = "API Gateway stage name"
  type        = string
}

variable "api_id" {
  description = "API Gateway ID"
  type        = string
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = var.api_id
  name        = var.api_gateway_stage
  auto_deploy = true

  tags = {
    Environment = var.environment
  }
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = aws_apigatewayv2_stage.stage.name
}
