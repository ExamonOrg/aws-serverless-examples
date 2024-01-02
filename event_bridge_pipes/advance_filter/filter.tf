resource "aws_iam_role_policy" "source" {
  role   = aws_iam_role.pipes.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
        ]
        Resource = [
          aws_sqs_queue.source.arn,
        ]
      },
    ]
  })
}

resource "aws_sqs_queue" "source" {
  name = "example-source"
}

resource "aws_iam_role_policy" "target" {
  role   = aws_iam_role.pipes.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:SendMessage",
        ]
        Resource = [
          aws_sqs_queue.target.arn,
        ]
      },
    ]
  })
}

resource "aws_sqs_queue" "target" {
  name = "example-target"
}

resource "aws_pipes_pipe" "filter_pipe" {
  depends_on = [aws_iam_role_policy.source, aws_iam_role_policy.target]
  name       = "example-pipe-filter"
  role_arn   = aws_iam_role.pipes.arn
  source     = aws_sqs_queue.source.arn
  target     = aws_sqs_queue.target.arn

  source_parameters {

    filter_criteria {
      filter {
        pattern = jsonencode({
          body = ["Your message here", "Your message there"]
        })
      }
    }
  }
}
