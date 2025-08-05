import os
import boto3
import json
from collections import Counter, defaultdict
from datetime import datetime

table_name = os.environ.get('DYNAMODB_TABLE_NAME')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    # Scan all feedback items
    resp = table.scan()
    items = resp.get('Items', [])

    # Aggregate sentiment counts
    sentiments = [item.get('sentiment', 'NEUTRAL').upper() for item in items]
    counts = Counter(sentiments)
    total = len(items)
    positive = counts.get('POSITIVE', 0)
    neutral = counts.get('NEUTRAL', 0)
    negative = counts.get('NEGATIVE', 0)

    # Trend: feedback count per day (last 7 days)
    trend = defaultdict(int)
    labels = []
    today = datetime.utcnow().date()
    for i in range(6, -1, -1):
        day = today.fromordinal(today.toordinal() - i)
        labels.append(day.strftime('%a'))
        trend[day.strftime('%Y-%m-%d')] = 0
    for item in items:
        created_at = item.get('created_at')
        try:
            date = datetime.strptime(created_at[:10], '%Y-%m-%d').date()
            key = date.strftime('%Y-%m-%d')
            if key in trend:
                trend[key] += 1
        except Exception:
            continue
    trend_data = [trend[day.strftime('%Y-%m-%d')] for day in [today.fromordinal(today.toordinal() - i) for i in range(6, -1, -1)]]

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({
            'total_feedback': total,
            'positive': positive,
            'neutral': neutral,
            'negative': negative,
            'trend': trend_data,
            'labels': labels
        })
    }
