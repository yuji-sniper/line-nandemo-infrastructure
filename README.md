# line-nandemo-infrastructure

## アプリ概要
色んな便利機能を持つLINEボットです。<br>
思いつき次第、機能追加していくつもり。

## 今ある機能
### 簡単リマインダー
以下のような3行のメッセージを送信することで、指定日時にリマインドをセットできます。<br>
![リマインダーチャット](./images/readme/reminder.png "リマインダーチャット")
- `りま`: リマインド機能を使用するということの指定。<br>
- `美容院`: リマインドするタスク。<br>
- `1610`: 次の16:10にリマインドしてねという指定。8桁で「07151630」のように先頭4桁で月日を指定すれば7/15 16:30にリマインド実行される<br>

### 簡単メモ
- メモを追加する
![めも追加](./images/readme/memo_store.png "メモ追加")
- メモリスト
![めも一覧](./images/readme/memo_list.png "メモ一覧")
- メモを見る
![めも詳細](./images/readme/memo_show.png "メモ詳細")
- メモを消す
![めも削除](./images/readme/memo_destroy.png "メモ削除")

## 主な使用技術
- AWS
  - Lambda（Python）
  - API Gateway
  - DynamoDB
  - EventBridge
- LINE Messagging API

## システム構成図
![システム構成図](./images/readme/aws_system.png "システム構成図")

## 技術的こだわりポイント
### LambdaレイヤーのPythonパッケージの動的な更新
- 課題<br>
PythonのLambdaレイヤーにライブラリを追加する場合、ローカルPCでPython環境を整えて`pip install`を実行し、それを現在のLambdaレイヤーのソースと差し替えてapplyを打つ流れになる。
  - ローカルPCで当該バージョンのPython環境を用意するのが手間
  - 複数人が携わる場合に環境差異がネック

- 工夫<br>
本Terraformリポジトリにrequirements.txtを配置。<br>
`terraform apply`時に以下が実行されるようにした。<br>
  - external data resourceでprepare_python_packages.shスクリプトを呼び出す。<br>
  - スクリプト内で、指定バージョンのPythonのDockerイメージをビルドし、requirements.txt記載の依存パッケージをインストールし、そのパスをJSONで返却。
  - archive_fileでそのパスをsource_dirとしてzipファイルを作成。
  - zipファイルをS3にアップロードし、Lambda layerとして登録する。

これにより、requirements.txtを更新してapplyを叩くのみでLambda Layerの更新が可能に。<br>
ローカル環境差異の問題も解決。
