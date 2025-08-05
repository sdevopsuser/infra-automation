environment         = "dev"
lambda_package      = "lambda_package/lambda_payload.zip"
lambda_memory_size  = 128
lambda_timeout      = 10
api_gateway_stage   = "dev"
subnet_ids = [
  "subnet-4743010b",
  "subnet-91dc48ea"
]
vpc_id              = "vpc-836e9ae8"
dashboard_image     = "dev-dashboard-image:latest"