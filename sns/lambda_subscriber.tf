data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "lambda_role" {
  name               = "role_lambda_handler1"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect   = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler1.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.my_topic.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "h1_lambda_function" {
  type        = "zip"
  source_dir  = "./handlers/h1"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "handler1" {
  function_name    = "handler1"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.h1_lambda_function.output_base64sha256
  filename         = data.archive_file.h1_lambda_function.output_path
  handler          = "src.main.lambda_handler"
  runtime          = "python3.11"
}

resource "aws_sns_topic" "my_topic" {
  name = "my-topic"
}

resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn                       = aws_sns_topic.my_topic.arn
  protocol                        = "lambda"
  endpoint                        = aws_lambda_function.handler1.arn
  confirmation_timeout_in_minutes = 3
}

# this can be how we fanout to multiple lambdas
resource "aws_sns_topic_subscription" "user_updates_sqs_target2" {
  topic_arn                       = aws_sns_topic.my_topic.arn
  protocol                        = "sqs"
  endpoint                        = aws_sqs_queue.my_queue.arn
  confirmation_timeout_in_minutes = 3
}
