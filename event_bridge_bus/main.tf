terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
       version = ">= 5.31.0"
    }
  }
}

resource "aws_cloudwatch_event_bus" "event_bridge_bus" {
    name = "my-event-bridge-bus2"
}


# Event Rule to capture events from S3 bucket
resource "aws_cloudwatch_event_rule" "event_rule" {
    depends_on = [aws_cloudwatch_event_bus.event_bridge_bus]
    name        = "my-event-rule"
    description = "Event rule for capturing events from S3 bucket"
    event_bus_name = aws_cloudwatch_event_bus.event_bridge_bus.arn

    event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail": {
    "eventName": [
      "PutObject",
      "DeleteObject",
      "DeleteObjects",
      "CreateObject",
      "ObjectCreated:*",
      "s3:ObjectCreated:*"
    ],
    "requestParameters": {
      "bucketName": [
        "bucket33298989"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_archive" "order" {
  name             = "order-archive"
  event_source_arn = aws_cloudwatch_event_bus.event_bridge_bus.arn
}

resource "aws_cloudwatch_event_target" "target_2" {
    depends_on = [aws_cloudwatch_event_rule.event_rule]
    event_bus_name = aws_cloudwatch_event_bus.event_bridge_bus.arn

    rule      = aws_cloudwatch_event_rule.event_rule.name
    arn       = aws_sqs_queue.my_queue.arn
    target_id = "target"
}
