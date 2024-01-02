resource "aws_sns_topic" "sns_src_dl" {
  name         = "mytopic-src-dl"
  display_name = "Topic"
  tags         = {
    Environment = "development"
  }
}

# FIFO queue
resource "aws_sqs_queue" "sqs_dest_dl" {
  name = "queue-dest-dl"
}

resource "aws_sns_topic_subscription" "subscription_dl" {
  topic_arn                       = aws_sns_topic.sns_src_dl.arn
  protocol                        = "sqs"
  endpoint                        = aws_sqs_queue.sqs_dest_dl.arn
  confirmation_timeout_in_minutes = 3
  redrive_policy                  = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
  })
}


resource "aws_sqs_queue" "dead_letter_queue" {
  name = "queue-deadletter"
}

resource "aws_sqs_queue_policy" "default" {

  queue_url = aws_sqs_queue.dead_letter_queue.id

  policy = data.aws_iam_policy_document.sqs_queue_policy.json
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  policy_id = "${aws_sqs_queue.dead_letter_queue.arn}/SNSDeadLetterQueue"

  statement {
    effect    = "Allow"
    actions   = ["SQS:SendMessage"]
    resources = [aws_sqs_queue.dead_letter_queue.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.sns_src_dl.arn]
    }
  }
}