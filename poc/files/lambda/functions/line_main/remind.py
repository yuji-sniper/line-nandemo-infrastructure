import boto3
import os
import uuid
from datetime import datetime, timedelta

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
        return "タスク名を指定するだ!"
    
    # time_strが数字で4桁または8桁かどうかチェック（4桁: 時間のみ, 8桁: 月日時分）
    if (not time_str.isdigit()) or (len(time_str) not in [4, 8]):
        return "リマインド日時は4桁または8桁の数字で指定するだ!"
    
    # time_strの末尾が0かどうかチェック
    if time_str[-1] != "0":
        return "リマインド日時は10分単位で指定するだ!"
    
    # 存在する日付かどうかチェック
    try:
        if len(time_str) == 8:
            time = datetime.strptime(time_str, '%m%d%H%M')
        else:
            time = datetime.strptime(time_str, '%H%M')
    except ValueError:
        return "リマインド日時は存在する日付を指定するだ!"
    
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
