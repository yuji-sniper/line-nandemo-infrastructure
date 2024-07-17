locals {
  python_packages_requirements_path = "${path.module}/files/lambda/layers/python_packages/requirements.txt"
  python_packages_output_path       = "${path.module}/outputs/lambda/layers/outputs/python_packages/output.zip"
  python_packages_venv_dir          = "${path.module}/outputs/lambda/venv"
  python_packages_source_dir        = "${path.module}/outputs/lambda/layers/sources/python_packages"
}


# レイヤー
resource "null_resource" "prepare_python_packages" {
  triggers = {
    "requirements_diff" = filebase64(local.python_packages_requirements_path)
  }

  provisioner "local-exec" {
    command = <<-EOF
      rm -rf ${local.python_packages_source_dir}/python &&
      mkdir -p ${local.python_packages_source_dir}/python &&
      docker pull python:3.11-slim &&
      docker run --rm -v $(pwd)/${local.python_packages_requirements_path}:/app/requirements.txt \
      -v $(pwd)/${local.python_packages_source_dir}/python:/app/python \
      python:3.11-slim /bin/sh -c "
        pip install -r /app/requirements.txt -t /app/python
      "
    EOF

    on_failure = fail
  }
}

data "archive_file" "python_packages_layer" {
  type        = "zip"
  source_dir  = local.python_packages_source_dir
  output_path = local.python_packages_output_path

  depends_on = [
    null_resource.prepare_python_packages
  ]
}

resource "aws_lambda_layer_version" "python_packages" {
  layer_name          = "${var.env}-${var.project}-python-packages"
  s3_bucket           = aws_s3_bucket.lambda_layers.id
  s3_key              = aws_s3_object.python_packages_layer.key
  source_code_hash    = data.archive_file.python_packages_layer.output_md5
  compatible_runtimes = ["python3.11"]
}

resource "aws_s3_object" "python_packages_layer" {
  bucket = aws_s3_bucket.lambda_layers.id
  key    = "python_packages_layer.zip"
  source = data.archive_file.python_packages_layer.output_path
  etag   = data.archive_file.python_packages_layer.output_md5
}


# LINEのメイン関数
data "archive_file" "line_main" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda/functions/line_main"
  output_path = "${path.module}/outputs/lambda/functions/line_main.zip"
}

resource "aws_lambda_function" "line_main" {
  function_name    = "${var.env}-${var.project}-line-main"
  role             = aws_iam_role.lambda_line_main.arn
  handler          = "lambda_function.lambda_handler"
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.line_main.key
  source_code_hash = data.archive_file.line_main.output_md5
  runtime          = "python3.11"
  timeout          = 15
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.python_packages.arn
  ]
  environment {
    variables = {
      CHANNEL_ACCESS_TOKEN   = "PleaseChange!"
      DYNAMO_REMINDERS_TABLE = aws_dynamodb_table.reminders.name
    }
  }
  lifecycle {
    ignore_changes = [
      environment
    ]
  }
}

resource "aws_lambda_permission" "line_main" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.line_main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.line_main.execution_arn}/*"
}

resource "aws_s3_object" "line_main" {
  bucket = aws_s3_bucket.lambda_functions.id
  key    = "line_main.zip"
  source = data.archive_file.line_main.output_path
  etag   = data.archive_file.line_main.output_md5
}


# LINEリマインド関数
data "archive_file" "line_remind" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda/functions/line_remind"
  output_path = "${path.module}/outputs/lambda/functions/line_remind.zip"
}

resource "aws_lambda_function" "line_remind" {
  function_name    = "${var.env}-${var.project}-line-remind"
  role             = aws_iam_role.lambda_line_remind.arn
  handler          = "lambda_function.lambda_handler"
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.line_remind.key
  source_code_hash = data.archive_file.line_remind.output_md5
  runtime          = "python3.11"
  timeout          = 15
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.python_packages.arn
  ]
  environment {
    variables = {
      CHANNEL_ACCESS_TOKEN = "PleaseChange!"
      DYNAMO_REMINDERS_TABLE = aws_dynamodb_table.reminders.name
    }
  }
  lifecycle {
    ignore_changes = [
      environment
    ]
  }
}

resource "aws_lambda_permission" "line_remind" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.line_remind.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_ten_minutes.arn
}

resource "aws_s3_object" "line_remind" {
  bucket = aws_s3_bucket.lambda_functions.id
  key    = "line_remind.zip"
  source = data.archive_file.line_remind.output_path
  etag   = data.archive_file.line_remind.output_md5
}
