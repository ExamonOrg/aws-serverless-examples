# FIFO topic
resource "aws_sns_topic" "sns_src_fifo" {
  name         = "mytopic-src.fifo"
  fifo_topic   = true
  display_name = "FIFO Topic"
  tags         = {
    Environment = "development"
  }
}

# FIFO queue
resource "aws_sqs_queue" "sqs_dest_fifo" {
  name       = "queue-dest.fifo"
  fifo_queue = true
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target3" {
  topic_arn                       = aws_sns_topic.sns_src_fifo.arn
  protocol                        = "sqs"
  endpoint                        = aws_sqs_queue.sqs_dest_fifo.arn
  confirmation_timeout_in_minutes = 3
}



