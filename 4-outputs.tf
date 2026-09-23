output "lambda_function_name" {
  value = aws_lambda_function.sns_publisher.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.lambda_notifications.arn
}
