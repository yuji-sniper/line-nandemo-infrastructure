import boto3
import json
import os
import requests
from datetime import datetime, timedelta

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('reminders')
    
    # 現在日時を%m%d%H%M形式で取得
    now = datetime.now() + timedelta(hours=9)
    now_str = now.strftime('%m%d%H%M')
    
    # DynamoDBから現在日時のリマインダーを取得
    data = table.scan(
        FilterExpression='remind_at = :now',
        ExpressionAttributeValues={':now': now_str}
    )
    reminders = data['Items']
    
    for reminder in reminders:
        send_reminder(reminder)
        table.delete_item(Key={'id': reminder['id']})


# リマインダー送信
def send_reminder(reminder):
    channel_access_token = os.environ['CHANNEL_ACCESS_TOKEN']
    push_api_endpoint = "https://api.line.me/v2/bot/message/push"
    user_id = reminder['user_id']
    task = reminder['task']
    
    # LINEへのリマインダー送信
    res_message = [
        {'type':'text','text':f"リマインド:\n{task}"}
    ]
    payload = {'to': user_id, 'messages': res_message}
    headers = {'content-type': 'application/json', 'Authorization': f'Bearer {channel_access_token}'}
    r = requests.post(push_api_endpoint, headers=headers, data=json.dumps(payload))
    print("LINEレスポンス:" + r.text)
