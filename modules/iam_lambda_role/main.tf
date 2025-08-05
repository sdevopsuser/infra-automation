resource "aws_iam_policy" "sns_publish" {
  name        = "lambda-sns-publish-${var.environment}"
  description = "Allow Lambda to publish to SNS topic"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "arn:aws:sns:ap-south-1:881168157995:critical-feedback-${var.environment}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_sns_publish" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.sns_publish.arn
}
resource "aws_iam_policy" "dynamodb_putitem" {
  name        = "lambda-dynamodb-putitem-${var.environment}"
  description = "Allow Lambda to put items in the feedback DynamoDB table"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = "arn:aws:dynamodb:ap-south-1:881168157995:table/customer-feedback-${var.environment}"
      }
    ]
  })
}

  name       = "lambda-dynamodb-putitem-attach-${var.environment}"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.dynamodb_putitem.arn
}
resource "aws_iam_policy_attachment" "lambda_dynamodb_putitem" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_putitem.arn
}

# Allow Lambda to scan the feedback DynamoDB table
resource "aws_iam_policy" "dynamodb_scan" {
  name        = "lambda-dynamodb-scan-${var.environment}"
  description = "Allow Lambda to scan the feedback DynamoDB table"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan"
        ],
        Resource = "arn:aws:dynamodb:ap-south-1:881168157995:table/customer-feedback-${var.environment}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_scan" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_scan.arn
}
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "comprehend_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}
    