resource "aws_iam_role" "lambda_role" {
  name               = "role_lambda_enrichment"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "enricher" {
  function_name = "enricher"
  filename      = "enrichment.zip"
  handler       = "src/main.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn
}