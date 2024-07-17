resource "aws_dynamodb_table" "reminders" {
  name           = "${var.env}-${var.project}-reminders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "remind_at"
    type = "S"
  }

  global_secondary_index {
    name            = "remind_at_index"
    hash_key        = "remind_at"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
}
