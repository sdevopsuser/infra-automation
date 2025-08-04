resource "aws_dynamodb_table" "feedback" {
  name           = "customer-feedback-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "feedback_id"

  attribute {
    name = "feedback_id"
    type = "S"
  }

  # Removed invalid attribute block; only feedback_id is required

  tags = {
    Environment = var.environment
    Name        = "Customer Feedback Table"
  }
}

