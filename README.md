# Customer Feedback Platform - Deployment & Outputs

## Deployment Process

1. **Set up AWS credentials and account ID as GitHub repository secrets:**
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ACCOUNT_ID`
2. **Push code to the main branch:**
   - Triggers the GitHub Actions CI/CD pipeline.
3. **CI/CD Pipeline Steps:**
   - Installs dependencies and Terraform
   - Builds and pushes the dashboard Docker image to ECR
   - Runs `terraform apply` with the correct tfvars for the environment
   - Deploys all AWS resources (API Gateway, Lambda, DynamoDB, SNS, ECS, ECR, etc.)
4. **Outputs:**
   - API endpoint: URL for submitting feedback
   - SNS topic ARN: For alerting/notifications
   - Dashboard URL: Public URL for analytics dashboard (ALB DNS)

## Environment Separation
- Each environment (dev, prod, etc.) uses its own `terraform.tfvars` file and separate state file.
- To deploy to a different environment, create a new tfvars file (e.g., `envs/prod/terraform.tfvars`) and use a separate backend/state configuration.


## How to Deploy (Environment-wise)

### Deploy to Dev (default)
1. **Just push your code to the `main` branch.**
   - The GitHub Actions workflow will automatically deploy using `envs/dev/terraform.tfvars` and store state in `dev/terraform.tfstate` in S3.

### Deploy to Prod
1. **Go to your repository's Actions tab on GitHub.**
2. Select the CI/CD workflow.
3. Click the **"Run workflow"** button (top right).
4. In the environment dropdown, select `prod`.
5. Click **"Run workflow"**.
   - The workflow will deploy using `envs/prod/terraform.tfvars` and store state in `prod/terraform.tfstate` in S3.

**Note:**
- Make sure `envs/prod/terraform.tfvars` exists and is updated with production values.
- No manual changes are needed in the workflow file for each environment.
- All state is managed in S3, so deployments are safe and isolated per environment.

## Outputs Example
- API endpoint: https://your-api-id.execute-api.ap-south-1.amazonaws.com/dev/
- SNS topic ARN: arn:aws:sns:ap-south-1:123456789012:your-topic
- Dashboard URL: http://your-alb-dns-name

## API Documentation

### 1. Submit Feedback

- **Endpoint:** `POST /feedback`
- **Description:** Submits user feedback.
- **Required Fields:**
  - `feedback_id` (string): Unique identifier for the feedback
  - `feedback_text` (string): The feedback content
  - `created_at` (string, ISO8601): Timestamp of submission
- **Request Body Example:**
  ```json
  {
    "feedback_id": "abc123",
    "feedback_text": "Great product!",
    "created_at": "2025-08-05T12:00:00Z"
  }
  ```
- **Response Example:**
  ```json
  {
    "status": "success",
    "message": "Feedback received"
  }
  ```

### 2. Get Analytics Summary

- **Endpoint:** `POST /analytics/summary`
- **Description:** Returns analytics summary for dashboard.
- **Request Body Example:**
  ```json
  {
    "date_range": "last_7_days"
  }
  ```
- **Response Example:**
  ```json
  {
    "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "counts": [12, 19, 7, 15, 22, 30, 18]
  }
  ```

## Design Decisions
- Chose AWS managed services (API Gateway, Lambda, DynamoDB, ECS, EventBridge, SNS) for scalability, reliability, and minimal ops overhead.
- Used Terraform for all infrastructure to ensure reproducibility and easy environment management.
- CI/CD via GitHub Actions for automated, repeatable deployments.

## Security Considerations
- IAM roles follow least privilege principle; Lambda and ECS tasks have only required permissions.
- Secrets (AWS keys, etc.) are managed via GitHub Secrets and not hardcoded.
- API Gateway endpoints require authentication for production (add Cognito/JWT as needed).
- S3 state bucket and DynamoDB table are encrypted and access-restricted.

## Monitoring & Observability
- CloudWatch Logs enabled for all Lambda functions and ECS services.
- CloudWatch Alarms and SNS notifications for error rates and critical failures.
- EventBridge triggers for custom alerts and operational events.
- API Gateway metrics and logs enabled for traffic and error tracking.

## Testing Strategy
- Unit tests for Lambda functions (see `tests/` folder for examples).
- Integration tests for API endpoints using curl/Postman.
- End-to-end tests for feedback submission and dashboard analytics.
- To run tests: see `tests/README.md` for instructions.

## Next Steps & Improvements
- Review and enhance IAM policies for even tighter security.
- Add API authentication (e.g., Cognito, JWT) for production use.
- Implement more granular monitoring (custom metrics, dashboards).
- Refactor Lambda and dashboard code for maintainability and performance.
- Investigate and fix any API live tracking or dashboard update issues.
- Add cost monitoring and optimization recommendations.
- Document troubleshooting steps for common issues.

## Required Environment Variables & Secrets

- **For CI/CD (GitHub Secrets):**
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_ACCOUNT_ID`

- **For Terraform (in tfvars files):**
  - `environment` (e.g., dev, prod)
  - `lambda_package` (path to Lambda deployment package)
  - `lambda_role_arn` (ARN of IAM role for Lambda)
  - `lambda_memory_size`
  - `lambda_timeout`
  - `analytics_lambda_package`
  - `analytics_lambda_handler`
  - `lambda_runtime`
  - `dynamodb_table_name`
  - `sns_topic_arn`
  - `dashboard_image` (ECR image URI for dashboard)
  - (Add any other variables used in your modules)

- **For Lambda/Dashboard (if any):**
  - Environment variables as defined in your Terraform code (e.g., `ENVIRONMENT`, `DYNAMODB_TABLE_NAME`, etc.)

---
For architecture details, see `architecture/README.md`.
