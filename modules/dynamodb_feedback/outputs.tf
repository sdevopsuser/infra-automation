output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.feedback.name
}