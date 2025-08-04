import os
import boto3
import json

SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '').strip()
if not SNS_TOPIC_ARN:
    raise RuntimeError("SNS_TOPIC_ARN environment variable not set or is empty after stripping.")

TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME', '').strip()
if not TABLE_NAME:
    raise RuntimeError("DYNAMODB_TABLE_NAME environment variable not set.")

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
comprehend = boto3.client('comprehend')

def lambda_handler(event, _):
    print("Lambda triggered. Event received:", json.dumps(event))
    # Parse feedback from both API Gateway (with 'body') and direct Lambda invocation (event is the body)
    if 'body' in event:
        body = event['body']
        if isinstance(body, str):
            try:
                body = json.loads(body)
            except json.JSONDecodeError as e:
                print(f"JSONDecodeError: {e}")
                return {"statusCode": 400, "body": json.dumps({"message": "Invalid JSON in request body."})}
        elif not isinstance(body, dict):
            return {"statusCode": 400, "body": json.dumps({"message": "Invalid body format."})}
    else:
        # Fallback: assume event itself is the body (Lambda always passes a dict)
        body = event

    feedback_id = body.get('feedback_id')
    feedback_text = body.get('feedback_text')
    created_at = body.get('created_at')

    missing_fields = []
    if not feedback_id:
        missing_fields.append("feedback_id")
    if not feedback_text:
        missing_fields.append("feedback_text")
    if not created_at:
        missing_fields.append("created_at")
    if missing_fields:
        print(f"Missing required fields in request: {missing_fields}")
        return {
            "statusCode": 400,
            "body": json.dumps({"message": f"Missing required fields: {', '.join(missing_fields)}."})
        }

# Sentiment analysis and DynamoDB/SNS operations with error handling
# Force update: dummy comment to change file hash
    try:
        sentiment_response = comprehend.detect_sentiment(
            Text=feedback_text,
            LanguageCode='en'
        )
        sentiment = sentiment_response.get('Sentiment', 'NEUTRAL')
        if not sentiment:
            print("Warning: 'Sentiment' not found in response, defaulting to 'NEUTRAL'.")
            sentiment = 'NEUTRAL'
    except Exception as e:
        print(f"Error during sentiment analysis: {e}")
        return {"statusCode": 500, "body": json.dumps({"message": f"Error during sentiment analysis: {str(e)}"})}
    try:
        table = dynamodb.Table(TABLE_NAME)
    except Exception as e:
        print(f"Error accessing DynamoDB table: {e}")
        return {"statusCode": 500, "body": json.dumps({"message": f"Error accessing DynamoDB table: {str(e)}"})}

    if sentiment.upper() == "NEGATIVE" and SNS_TOPIC_ARN:
        print("Publishing critical feedback to SNS topic:", SNS_TOPIC_ARN)
        try:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=(
                    f"Critical feedback received:\n"
                    f"Feedback ID: {feedback_id}\n"
                    f"Created At: {created_at}\n"
                    f"Sentiment: {sentiment}\n"
                    f"Feedback Text: {feedback_text}"
                ),
                Subject="Critical Feedback Alert"
            )
            print("SNS publish successful.")
        except Exception as e:
            print(f"Error publishing to SNS: {e}")
            return {"statusCode": 500, "body": json.dumps({"message": f"Error publishing to SNS: {str(e)}"})}

    # Store feedback in DynamoDB
    try:
        table.put_item(
            Item={
                'feedback_id': feedback_id,
                'feedback_text': feedback_text,
                'created_at': created_at,
                'sentiment': sentiment
            }
        )
    except Exception as e:
        print(f"Error storing feedback in DynamoDB: {e}")
        return {"statusCode": 500, "body": json.dumps({"message": f"Error storing feedback in DynamoDB: {str(e)}"})}

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Feedback was analyzed and successfully stored",
            "sentiment": sentiment,
            "feedback_id": feedback_id,
            "created_at": created_at
        })
    }
