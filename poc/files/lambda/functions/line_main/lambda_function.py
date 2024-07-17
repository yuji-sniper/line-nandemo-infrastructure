import boto3
import json
import os
import requests
import uuid
from datetime import datetime, timedelta

def lambda_handler(event, context):
    channel_access_token = os.environ['CHANNEL_ACCESS_TOKEN']
    reply_api_endpoint = "https://api.line.me/v2/bot/message/reply"
    res_message = "なんもできんかっただ.."
    modes = [
        {
            "name": ["リマインド", "りま"],
            "function": remind
        },
    ]
    
    # イベント情報の取得
    body = json.loads(event['body'])
    message = body['events'][0]['message']['text']
    reply_token = body['events'][0]['replyToken']
    user_id = body['events'][0]['source']['userId']
    
    # メッセージの1行目を取得
    mode = message.split("\n")[0]
    
    # モードに応じた処理を実行
    for m in modes:
        if mode in m["name"]:
            res_message = m["function"](message, user_id)

    # LINEへのレスポンス作成
    resmessage = [
        {'type':'text','text':res_message}
    ]
    payload = {'replyToken': reply_token, 'messages': resmessage}
    # カスタムヘッダーの生成(dict形式)
    headers = {'content-type': 'application/json', 'Authorization': f'Bearer {channel_access_token}'}
    # headersにカスタムヘッダーを指定
    r = requests.post(reply_api_endpoint, headers=headers, data=json.dumps(payload))
    print("LINEレスポンス:" + r.text)
    return


# リマインド機能
def remind(message, user_id):
    parts = message.split("\n")
    
    # 行数が正しいかチェック
    if len(parts) < 3:
        return "なんか形式間違っとるだ!"
    
    task = parts[1].strip()
    time_str = parts[2].strip()
    
    # taskが空文字かどうかチェック
    if task == "":
        return "タスク名を入力するだ!"
    
    # time_strが数字で4桁または8桁かどうかチェック（4桁: 時間のみ, 8桁: 月日時分）
    if (not time_str.isdigit()) or (len(time_str) not in [4, 8]):
        return "リマインド日時は4桁または8桁の数字で入力するだ!"
    
    # time_strの末尾が0かどうかチェック
    if time_str[-1] != "0":
        return "10分単位で入力するだ!"
    
    # 存在する日付かどうかチェック
    try:
        if len(time_str) == 8:
            time = datetime.strptime(time_str, '%m%d%H%M')
        else:
            time = datetime.strptime(time_str, '%H%M')
    except ValueError:
        return "存在する日付を入力するだ!"
    
    # time_strが4桁(時間のみ)の場合、次に来る該当日時を計算して8桁に変換
    if len(time_str) == 4:
        now = datetime.now() + timedelta(hours=9)
        time = datetime(now.year, now.month, now.day, time.hour, time.minute)
        if time <= now:
            time = time.replace(day=now.day + 1)
        time_str = time.strftime('%m%d%H%M')
    
    # リマインド登録
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['DYNAMO_REMINDERS_TABLE']
    table = dynamodb.Table(table_name)
    remider_id = str(uuid.uuid4())
    table.put_item(Item={
        'id': remider_id,
        'user_id': user_id,
        'task': task,
        'remind_at': time_str
    })
    
    # timeを「月/日 時:分」形式に変換
    time = time.strftime('%m/%d %H:%M')
    
    return f"「{task}」を\n{time}\nにリマインドするだ!"
