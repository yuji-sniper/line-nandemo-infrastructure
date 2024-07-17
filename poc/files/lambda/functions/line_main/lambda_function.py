import json
import os
import requests
from remind import remind

def lambda_handler(event, context):
    channel_access_token = os.environ['CHANNEL_ACCESS_TOKEN']
    reply_api_endpoint = "https://api.line.me/v2/bot/message/reply"
    res_message = "なんもできんかっただ.."
    modes = [
        {
            "name": ["リマインド", "りま", "リマ"],
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
