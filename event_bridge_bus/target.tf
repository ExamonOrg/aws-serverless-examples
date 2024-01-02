resource "aws_sqs_queue" "my_queue" {
    name                      = "my-queue"
    delay_seconds             = 0
    max_message_size          = 262144
    message_retention_seconds = 345600
    visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "schedule-event-policy" {
  queue_url = aws_sqs_queue.my_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:SendMessage", "sqs:ReceiveMessage"],
      "Resource": "${aws_sqs_queue.my_queue.arn}"
    }
  ]
}
POLICY
}