# 10分ごとに実行するルール
resource "aws_cloudwatch_event_rule" "every_ten_minutes" {
  name                = "${var.env}-${var.project}-every-ten-minutes"
  schedule_expression = "cron(0/10 * * * ? *)"
  state               = "DISABLED"
}

# LINEリマインドLambda関数を10分ごとに実行する
resource "aws_cloudwatch_event_target" "line_remind" {
  target_id = "${var.env}-${var.project}-line-remind"
  rule      = aws_cloudwatch_event_rule.every_ten_minutes.name
  arn       = aws_lambda_function.line_remind.arn
}
