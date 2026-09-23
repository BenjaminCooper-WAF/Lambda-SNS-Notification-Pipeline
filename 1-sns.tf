resource "aws_sns_topic" "lambda_notifications" {
  name = "lambda-to-sns-topic"
}
