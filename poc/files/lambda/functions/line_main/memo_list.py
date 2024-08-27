import os
import boto3
from boto3.dynamodb.conditions import Key

def memo_list(message, user_id):
    # メモ取得
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['DYNAMO_MEMOS_TABLE']
    table = dynamodb.Table(table_name)
    response = table.query(
        IndexName='user_id_index',
        KeyConditionExpression=Key('user_id').eq(user_id),
        ScanIndexForward=True
    )
    items = response['Items']

    if len(items) == 0:
        return "メモが見つからんかっただ.."

    return "\n".join(f"・{memo['title']}" for memo in items)
