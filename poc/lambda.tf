# レイヤー
data "archive_file" "python_requests_layer" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/layers/python_requests"
  output_path = "${path.module}/artifacts/python_requests_layer.zip"
}

resource "aws_lambda_layer_version" "python_requests" {
  layer_name          = "${var.env}_${var.project}_python_requests"
  vesion              = 1
  s3_bucket           = aws_s3_bucket.lambda_layers.id
  s3_key              = aws_s3_object.python_requests_layer.key
  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_layer_version_permission" "python_requests" {
  statement_id   = "AllowExecutionFromLambda"
  layer_name     = aws_lambda_layer_version.python_requests.arn
  version_number = aws_lambda_layer_version.python_requests.version
  principal      = "lambda.amazonaws.com"
  action         = "lambda:GetLayerVersion"
}

resource "aws_s3_object" "python_requests_layer" {
  bucket = aws_s3_bucket.lambda_layers.id
  key    = "python_requests_layer.zip"
  source = data.archive_file.python_requests_layer.output_path
  etag   = data.archive_file.python_requests_layer.output_md5
}


# LINEのメイン関数
data "archive_file" "line_main" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/functions/line_main"
  output_path = "${path.module}/artifacts/line_main.zip"
}

resource "aws_lambda_function" "line_main" {
  function_name    = "${var.env}_${var.project}_line_main"
  role             = aws_iam_role.lambda_line_main.arn
  handler          = "lambda_function.lambda_handler"
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.line_main.key
  source_code_hash = data.archive_file.line_main.output_md5
  runtime          = "python3.11"
  timeout          = 15
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.python_requests.arn
  ]
  environment {
    variables = {
      CHANNEL_ACCESS_TOKEN = "PleaseChange!"
    }
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
  source_dir  = "${path.cwd}/files/lambda/functions/line_remind"
  output_path = "${path.module}/artifacts/line_remind.zip"
}

resource "aws_lambda_function" "line_remind" {
  function_name    = "${var.env}_${var.project}_line_remind"
  role             = aws_iam_role.lambda_line_remind.arn
  handler          = "lambda_function.lambda_handler"
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.line_remind.key
  source_code_hash = data.archive_file.line_remind.output_md5
  runtime          = "python3.11"
  timeout          = 15
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.python_requests.arn
  ]
  environment {
    variables = {
      CHANNEL_ACCESS_TOKEN = "PleaseChange!"
    }
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
