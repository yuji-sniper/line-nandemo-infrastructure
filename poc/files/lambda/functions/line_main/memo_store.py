import boto3
import os
import uuid
from datetime import datetime
from boto3.dynamodb.conditions import Key

def memo_store(message, user_id):
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['DYNAMO_MEMOS_TABLE']
    table = dynamodb.Table(table_name)

    parts = message.split("\n")
    
    # 行数が正しいかチェック
    if len(parts) < 3:
        return "なんか形式間違っとるだ!"
    
    title = parts[1].strip()
    content = "\n".join(parts[2:])
    
    # titleが空文字かどうかチェック
    if title == "":
        return "タイトルを指定するだ!"
    # titleが20文字以内かどうかチェック
    if len(title) > 20:
        return "タイトルは20文字以内で指定するだ!"
    
    # contentが空文字かどうかチェック
    if content == "":
        return "内容を指定するだ!"
    # contentが200文字以内かどうかチェック（改行コードは除く）
    if len(content.replace("\n", "")) > 200:
        return "内容は200文字以内で指定するだ!"
    
    # すでに同じタイトルのメモがあればそれを更新
    response = table.query(
        IndexName='user_id_title_index',
        KeyConditionExpression=
            Key('user_id').eq(user_id) &
            Key('title').eq(title)
    )
    items = response['Items']
    if len(items) > 0:
        memo = items[0]
        table.update_item(
            Key={
                'id': memo['id']
            },
            UpdateExpression="set content = :c",
            ExpressionAttributeValues={
                ':c': content
            }
        )
        return f"「{title}」のメモを更新しただ!"
    
    # メモ登録
    memo_id = str(uuid.uuid4())
    created_at = int(datetime.now().timestamp())
    table.put_item(Item={
        'id': memo_id,
        'user_id': user_id,
        'title': title,
        'content': content,
        'created_at': created_at
    })
    
    return f"「{title}」をメモに追加しただ!"
