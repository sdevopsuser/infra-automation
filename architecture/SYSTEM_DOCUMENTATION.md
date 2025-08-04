# Customer Feedback Platform - System Documentation

## Overview
This document describes the architecture, components, and deployment of the Customer Feedback Platform. The platform is designed to ingest, process, analyze, and visualize customer feedback from multiple channels in real time, with automated alerting and reporting.

---

## Architecture Diagram

> See `architecture/architecture-diagram.png` for a visual overview of the system. (Add your diagram here.)

---

## Components

### 1. API Gateway
- **Purpose:** Exposes RESTful endpoints for feedback submission from web, mobile, and other channels.
- **Resource:** `aws_apigatewayv2_api`, `aws_apigatewayv2_stage`, `aws_apigatewayv2_integration`, `aws_apigatewayv2_route`
- **Deployed by:** `lambda_api_gateway` and `api_gateway_stage` modules

### 2. Lambda Function
- **Purpose:** Processes incoming feedback, performs sentiment analysis, and triggers workflows.
- **Resource:** `aws_lambda_function`
- **IAM Role:** `iam_lambda_role` module
- **Deployment Package:** `lambda_package/lambda_payload.zip`

### 3. DynamoDB Table
- **Purpose:** Stores feedback data and analysis results.
- **Resource:** `aws_dynamodb_table` in `dynamodb_feedback` module
- **Table Name:** `customer-feedback-${var.environment}`
- **Primary Key:** `feedback_id` (String)

### 4. Event-Driven Alerts
- **Purpose:** Notifies relevant teams when critical feedback is detected.
- **Resource:** `aws_sns_topic` in `event_alerting` module

### 5. Analytics Dashboard
- **Purpose:** Visualizes feedback trends and insights for customer experience teams.
- **Resource:** ECS Cluster, Service, Task Definition, ALB, Security Groups in `analytics_dashboard` module
- **Container Image:** `public.ecr.aws/your-org/analytics-dashboard:latest`
- **Network:** Deployed in specified VPC and subnets

### 6. CI/CD Pipeline
- **Purpose:** Automates deployment and testing of infrastructure and application code.
- **Resource:** S3 bucket for artifacts, pipeline module, and GitHub Actions workflow (`.github/workflows/ci-cd.yml`)

---

## Data Flow
1. **Feedback Submission:** Clients send feedback to the API Gateway endpoint.
2. **Processing:** API Gateway triggers the Lambda function, which processes and analyzes the feedback.
3. **Storage:** Processed feedback is stored in DynamoDB.
4. **Alerting:** If critical feedback is detected, Lambda publishes a message to the SNS topic.
5. **Visualization:** Feedback data is visualized in the analytics dashboard running on ECS, accessible via ALB.
6. **Reporting:** Periodic reports can be generated from DynamoDB data (extend Lambda or add reporting Lambda as needed).

---

## Deployment
- **Terraform:** All AWS resources are managed via Terraform modules.
- **Environments:** Use `terraform.tfvars` files for each environment (e.g., `dev`, `prod`).
- **Lambda Package:** Place your deployment zip at `lambda_package/lambda_payload.zip`.
- **Dashboard Image:** Push your dashboard image to ECR or another registry and update the variable.
- **CI/CD:** GitHub Actions workflow automates validation, testing, and deployment.

---

## Security & Best Practices
- IAM roles are least-privilege for Lambda and ECS tasks.
- All resources are tagged with environment and purpose.
- Sensitive values (e.g., secrets) should be managed via AWS Secrets Manager or SSM Parameter Store (not hardcoded).
- Use version control for all Terraform and application code.

---

## Testing
- Unit and integration tests should be added in the `tests/` directory.
- The CI/CD pipeline runs tests on every push to `main`.

---

## API Documentation
- See `api-docs/openapi.yaml` for the OpenAPI specification of the feedback submission endpoint.

---

## Contact & Support
- For questions or issues, contact the DevOps or Platform Engineering team.
