# terraform/main.tf

provider "aws" {
  region = var.region
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "../"
  output_path = "../lambda_function.zip"
  excludes    = [
    ".git/*",
    "terraform/*",
    "build.sh",
    "README.md"
  ]
}

data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "../gems"
  output_path = "../lambda_layer.zip"
}

resource "aws_lambda_layer_version" "gems" {
  filename   = data.archive_file.lambda_layer_zip.output_path
  layer_name = "slack-link-unfurler-gems"
  
  compatible_runtimes = ["ruby2.7"]
  
  description = "Dependencies for the Slack Link Unfurler Lambda function"
}

resource "aws_lambda_function" "slack_link_unfurler" {
  filename         = data.archive_file.lambda_function_zip.output_path
  function_name    = "slack-link-unfurler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_function_zip.output_path)
  runtime          = "ruby2.7"
  layers           = [aws_lambda_layer_version.gems.arn]
  environment {
    variables = {
      SLACK_ACCESS_TOKEN      = var.slack_access_token
      BASECAMP_CLIENT_ID      = var.basecamp_client_id
      BASECAMP_CLIENT_SECRET  = var.basecamp_client_secret
    }
  }
}

resource "aws_lambda_permission" "allow_slack" {
  statement_id  = "AllowExecutionFromSlack"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_link_unfurler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.slack_event_subscription_arn
}

data "aws_lambda_function" "function" {
  function_name = aws_lambda_function.slack_link_unfurler.function_name
}

output "aws_lambda_function_url" {
  value = data.aws_lambda_function.function.invoke_arn
}
