# line-nandemo-infrastructure

## アプリ概要
色んな便利機能を持つLINEボットです。<br>
思いつき次第機能追加していくつもりです。

## 今ある機能
### 簡単リマインダー
以下のような3行のメッセージを送信することで、指定日時にリマインドをセットできます。<br>
![リマインダーチャット](./images/readme/reminder.png "リマインダーチャット")
`りま`: リマインド機能を使用するということの指定。<br>
`美容院`: リマインドするタスク。<br>
`1610`: 次の16:10にリマインドしてねという指定。8桁で「07151630」のように先頭4桁で月日を指定すれば7/15 16:30にリマインド実行される<br>

## 主な使用技術
- AWS
  - Lambda（Python）
  - API Gateway
  - DynamoDB
  - EventBridge
- LINE Messagging API

## システム構成図
![システム構成図](./images/readme/aws_system.png "システム構成図")
