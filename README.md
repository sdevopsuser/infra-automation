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

## How to Deploy for a New Environment
1. Copy `envs/dev/terraform.tfvars` to `envs/prod/terraform.tfvars` and update values as needed.
2. Use Terraform workspaces or backend configuration to separate state files.
3. Update the CI/CD pipeline to use the correct tfvars and workspace for the target environment.

## Outputs Example
- API endpoint: https://your-api-id.execute-api.ap-south-1.amazonaws.com/dev/
- SNS topic ARN: arn:aws:sns:ap-south-1:123456789012:your-topic
- Dashboard URL: http://your-alb-dns-name

---
For architecture details, see `architecture/README.md`.
