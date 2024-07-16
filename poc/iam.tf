# Lambda関連
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_line_main" {
  name               = "${var.env}_${var.project}_lambda_line_main"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "lambda_line_remind" {
  name               = "${var.env}_${var.project}_lambda_line_remind"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  roles = [
    aws_iam_role.lambda_line_main.name,
    aws_iam_role.lambda_line_remind.name,
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_dynamodb" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.env}_${var.project}_*"]
  }
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name   = "${var.env}_${var.project}_lambda_dynamodb"
  policy = data.aws_iam_policy_document.lambda_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  roles = [
    aws_iam_role.lambda_line_main.name,
    aws_iam_role.lambda_line_remind.name,
  ]
  policy_arn = aws_iam_policy.lambda_line_main_dynamodb.arn
}


# API Gateway関連
data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_line_main" {
  name               = "${var.env}_${var.project}_api_gateway_line_main"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_logs" {
  role       = aws_iam_role.api_gateway_line_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_lambda" {
  role       = aws_iam_role.api_gateway_line_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}


# EventBridge Scheduler関連
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler_line_remind" {
  name               = "${var.env}_${var.project}_lambda_scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

data "aws_iam_policy_document" "lambda_scheduler" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.line_remind.arn]
  }
}

resource "aws_iam_policy" "lambda_scheduler" {
  name   = "${var.env}_${var.project}_lambda_scheduler"
  policy = data.aws_iam_policy_document.lambda_scheduler.json
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  roles = [
    aws_iam_role.scheduler_line_remind.name,
  ]
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}
