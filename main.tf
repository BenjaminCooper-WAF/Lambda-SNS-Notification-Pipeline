terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_sns_topic" "lambda_notifications" {
  name = "lambda-to-sns-topic"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-to-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-to-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.lambda_notifications.arn
      }
    ]
  })
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}


resource "aws_lambda_function" "sns_publisher" {
  function_name = "lambda-to-sns-publisher"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_notifications.arn
    }
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.sns_publisher.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.lambda_notifications.arn
}