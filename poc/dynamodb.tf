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

resource "aws_dynamodb_table" "memos" {
  name          = "${var.env}-${var.project}-memos"
  billing_mode  = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1
  hash_key      = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "title"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

  global_secondary_index {
    name            = "user_id_index"
    hash_key        = "user_id"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }

  global_secondary_index {
    name            = "user_id_title_index"
    hash_key        = "user_id"
    range_key       = "title"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }

  global_secondary_index {
    name            = "created_at_index"
    hash_key        = "created_at"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
}
