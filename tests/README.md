# Testing Strategy

## Overview
This folder contains test scripts and documentation for the Customer Feedback Platform.

## Types of Tests
- Unit tests for Lambda functions (see `lambda/` folder)
- Integration tests for API Gateway and DynamoDB
- End-to-end tests for feedback submission and dashboard

## Example Unit Test (Python, pytest)
```python
# test_lambda_feedback.py
import lambda_function

def test_feedback_handler():
    event = {
        "feedback_id": "test1",
        "feedback_text": "Test feedback",
        "created_at": "2025-08-05T12:00:00Z"
    }
    result = lambda_function.lambda_handler(event, None)
    assert result["status"] == "success"
```

## Example Integration Test (curl)
```sh
curl -X POST "https://<api-id>.execute-api.ap-south-1.amazonaws.com/feedback" \
  -H "Content-Type: application/json" \
  -d '{"feedback_id": "test2", "feedback_text": "Integration test", "created_at": "2025-08-05T12:00:00Z"}'
```

## Example End-to-End Test
- Submit feedback via API
- Check dashboard for updated analytics (manual or automated browser test)

## How to Run
1. Run unit tests:
   ```sh
   pytest tests/
   ```
2. Run integration tests:
   ```sh
   bash tests/integration.sh
   ```
3. For end-to-end, use browser or automation tool (e.g., Selenium).
