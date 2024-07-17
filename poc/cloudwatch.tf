locals {
  retension_in_days = 60
  lambda_functions = toset([
    aws_lambda_function.line_main.function_name,
    aws_lambda_function.line_remind.function_name,
  ])
}

resource "aws_cloudwatch_log_group" "lambda_functions" {
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.value}"
  retention_in_days = local.retension_in_days
}
