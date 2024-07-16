# 10分ごとに実行するルール
resource "aws_cloudwatch_event_rule" "every_ten_minutes" {
  name                = "${var.env}_${var.project}_every_ten_minutes"
  schedule_expression = "cron(0/10 * * * ? *)"
}

# LINEリマインドLambda関数を10分ごとに実行する
resource "aws_cloudwatch_event_target" "line_remind" {
  target_id = "${var.env}_${var.project}_line_remind"
  rule      = aws_cloudwatch_event_rule.every_ten_minutes.name
  arn       = aws_lambda_function.line_remind.arn
  role_arn  = aws_iam_role.scheduler_line_remind.arn
}
