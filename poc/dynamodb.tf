resource "aws_dynamodb_table" "reminders" {
  name         = "${var.env}_${var.project}_reminders"
  billing_mode = "PROVISIONED"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "user_id"
    type = "S"
  }
  attribute {
    name = "task"
    type = "S"
  }
  attribute {
    name = "remind_at"
    type = "S"
  }
}
