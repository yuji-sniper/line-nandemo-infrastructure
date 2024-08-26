import os
import boto3
from boto3.dynamodb.conditions import Key

def memo_destroy(message, user_id):
    parts = message.split("\n")
    title = parts[1].strip()
    
    # titleが空文字かどうかチェック
    if title == "":
        return "タイトルを指定するだ!"
    
    # メモ取得
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['DYNAMO_MEMOS_TABLE']
    table = dynamodb.Table(table_name)
    response = table.query(
        IndexName='user_id_title_index',
        KeyConditionExpression=
            Key('user_id').eq(user_id) &
            Key('title').eq(title)
    )
    items = response['Items']

    if len(items) == 0:
        return "メモが見つからんかっただ.."
    
    memo = items[0]
    table.delete_item(
        Key={
            'id': memo['id']
        }
    )
    return f"「{title}」をメモから削除しただ!"
