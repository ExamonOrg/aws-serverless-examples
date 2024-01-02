resource "aws_sqs_queue" "enrichment_source" {
  name = "enrichment_source"
}

resource "aws_sqs_queue" "enrichment_target" {
  name = "enrichment_target"
}


resource "aws_iam_role_policy" "source_policy" {
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
          aws_sqs_queue.enrichment_source.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "target_policy" {
  role   = aws_iam_role.pipes.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sqs:*",
          "cloudWatchLogs:CreateLogStream",
          "cloudWatchLogs:PutLogEvents",
        ]
        Resource = [
          aws_sqs_queue.enrichment_target.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "pipe_policy" {
  role   = aws_iam_role.pipes.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "lambda:*",
        ]
        Resource = [
          aws_lambda_function.enricher.arn,
        ]
      },
    ]
  })
}

resource "aws_pipes_pipe" "enrichment_pipe" {
  name       = "example-pipe-enrichment"
  role_arn   = aws_iam_role.pipes.arn
  source     = aws_sqs_queue.enrichment_source.arn
  target     = aws_sqs_queue.enrichment_target.arn
  enrichment = aws_lambda_function.enricher.arn
}
