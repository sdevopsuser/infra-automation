variable "environment" {
  description = "Deployment environment"
  type        = string
}

resource "aws_s3_bucket" "cicd_artifacts" {
  bucket = "cicd-artifacts-${var.environment}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "cicd_bucket_name" {
  value = aws_s3_bucket.cicd_artifacts.bucket
}
