resource "aws_sns_topic" "user_updates" {
  name         = "my-topic-states"
  display_name = "My SNS Topic"
}

resource "aws_sns_topic_subscription" "email_me" {
  endpoint  = var.email
  protocol  = "email"
  topic_arn = aws_sns_topic.user_updates.arn
}
