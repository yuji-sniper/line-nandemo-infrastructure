resource "aws_api_gateway_rest_api" "line_main" {
  name = "${var.env}-${var.project}-line-main"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "line_main"
      version = "1.0"
    }
    paths = {
      "/" = {
        options = {
          x-amazon-apigateway-integration = {
            type = "mock"
            requestTemplates = {
              "application/json" = "{ \"statusCode\": 200 }"
            }
            responses = {
              default = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
                responseTemplates = {
                  "application/json" = ""
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "Default response for CORS method"
              headers = {
                "Access-Control-Allow-Headers" = {
                  type = "string"
                }
                "Access-Control-Allow-Methods" = {
                  type = "string"
                }
                "Access-Control-Allow-Origin" = {
                  type = "string"
                }
              }
            }
          }
        }
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = aws_lambda_function.line_main.invoke_arn
            credentials          = aws_iam_role.api_gateway_line_main.arn
          }
          responses = {
            "200" = {
              description = "Default response for POST method"
              headers = {
                "Access-Control-Allow-Headers" = {
                  type = "string"
                }
                "Access-Control-Allow-Methods" = {
                  type = "string"
                }
                "Access-Control-Allow-Origin" = {
                  type = "string"
                }
              }
            }
            "default" = {
              description = "Default response for POST method"
              headers = {
                "Access-Control-Allow-Headers" = {
                  type = "string"
                }
                "Access-Control-Allow-Methods" = {
                  type = "string"
                }
                "Access-Control-Allow-Origin" = {
                  type = "string"
                }
              }
            }
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_gateway_response" "line_main_default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.line_main.id
  status_code   = "400"
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "line_main" {
  rest_api_id = aws_api_gateway_rest_api.line_main.id
  depends_on = [
    aws_api_gateway_rest_api.line_main,
    aws_api_gateway_gateway_response.line_main_default_4xx,
  ]
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
