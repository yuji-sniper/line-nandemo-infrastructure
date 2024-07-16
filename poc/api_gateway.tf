resource "aws_api_gateway_rest_api" "line_main" {
  name = "${var.env}_${var.project}_line_main"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "line_main"
      version = "1.0"
    }
    paths = {
      "/" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = aws_lambda_function.line_main.invoke_arn
            credentials          = aws_iam_role.api_gateway_line_main.arn
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "line_main" {
  rest_api_id = aws_api_gateway_rest_api.line_main.id
  depends_on  = [aws_api_gateway_method.line_main]
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.line_main))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "line_main" {
  deployment_id = aws_api_gateway_deployment.line_main.id
  rest_api_id   = aws_api_gateway_rest_api.line_main.id
  stage_name    = "prod"
}

data "aws_iam_policy_document" "line_main_api_gateway_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.line_main.execution_arn}/*"]
  }
}

resource "aws_api_gateway_rest_api_policy" "line_main" {
  rest_api_id = aws_api_gateway_rest_api.line_main.id
  policy      = data.aws_iam_policy_document.line_main_api_gateway_policy.json
}
