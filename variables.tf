variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "The environment variable must be either 'dev' or 'prod'."
  }
}

variable "lambda_package" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda function"
  type        = number
  validation {
    condition     = contains([128, 256, 512, 1024, 2048, 3008], var.lambda_memory_size)
    error_message = "Lambda memory size must be one of: 128, 256, 512, 1024, 2048, or 3008 MB."
  }
}


variable "lambda_timeout" {
  description = "Timeout for Lambda function in seconds"
  type        = number
  default     = 3
}
variable "api_gateway_stage" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}


variable "dashboard_image" {
  description = "Container image for the analytics dashboard"
  type        = string
  default     = "dummy-value-replaced-by-ci-cd"  # This default is just to prevent prompting
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "vpc_id" {
  description = "VPC ID for ECS tasks"
  type        = string
}


