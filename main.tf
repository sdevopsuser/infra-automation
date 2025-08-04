output "api_endpoint" {
  description = "The endpoint URL of the deployed API Gateway."
  value       = module.lambda_api_gateway.api_endpoint
}

output "sns_topic_arn" {
  value = module.event_alerting.sns_topic_arn
}

module "iam_lambda_role" {
  source      = "./modules/iam_lambda_role"
  environment = var.environment
}

module "lambda_api_gateway" {
  source              = "./modules/lambda_api_gateway"
  lambda_package      = var.lambda_package
  lambda_role_arn     = module.iam_lambda_role.lambda_role_arn
  lambda_memory_size  = var.lambda_memory_size
  lambda_timeout      = var.lambda_timeout
  environment         = var.environment
  dynamodb_table_name = module.dynamodb_feedback.dynamodb_table_name
  sns_topic_arn       = module.event_alerting.sns_topic_arn
}
module "api_gateway_stage" {
  source            = "./modules/api_gateway_stage"
  environment       = var.environment
  api_gateway_stage = var.api_gateway_stage
  api_id            = module.lambda_api_gateway.api_id
}

module "dynamodb_feedback" {
  source      = "./modules/dynamodb_feedback"
  environment = var.environment
}

module "event_alerting" {
  source               = "./modules/event_alerting"
  environment          = var.environment
  lambda_function_arn  = module.lambda_api_gateway.lambda_function_arn
}

module "cloudwatch_monitoring" {
  source               = "./modules/cloudwatch_monitoring"
  lambda_function_name = module.lambda_api_gateway.lambda_function_name # Replace with actual Lambda function name output if available
}

module "cicd_pipeline" {
  source      = "./modules/cicd_pipeline"
  environment = var.environment
}

module "analytics_dashboard" {
  source          = "./modules/analytics_dashboard"
  environment     = var.environment
  dashboard_image = var.dashboard_image
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
}
