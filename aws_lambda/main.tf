terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "AWSLambdaSample::AWSLambdaSample.Function::FunctionHandler"
  runtime       = "dotnet8"

  filename         = "C:/Users/felip/Documents/GitHub/sample-aws-lambda/publish/aws-lambda-sample.zip"
  source_code_hash = filebase64sha256("C:/Users/felip/Documents/GitHub/sample-aws-lambda/publish/aws-lambda-sample.zip")

  environment {
    variables = {
        ASPNETCORE_ENVIRONMENT = "Development"
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function URL
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"  # Pode ser "AWS_IAM" se precisar de autenticação

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age          = 86400
  }
}

# Lambda Permission for Function URL
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromFunctionURL"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "*"

  function_url_auth_type = "NONE"
}

# Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "lambda_function_url" {
  description = "URL of the Lambda function"
  value       = aws_lambda_function_url.lambda_url.function_url
}