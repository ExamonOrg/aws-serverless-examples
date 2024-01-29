resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "example-state-machine-logging"
  role_arn   = aws_iam_role.example_role.arn
  type = "EXPRESS"
  logging_configuration {
    include_execution_data = true
    level = "ALL"
    log_destination = "${aws_cloudwatch_log_group.mygroup.arn}:*"
  }
  definition = <<EOF
{
    "Comment": "A simple Step Functions state machine",
    "StartAt": "Hello",
    "States": {
        "Hello": {
          "Type": "Pass",
          "Result": "Hello",
          "Next": "World"
        },
        "World": {
          "Type": "Pass",
          "Result": "World",
          "End": true
        }
    }
}
EOF
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-111"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_group" "mygroup" {
  name = "aws_cloudwatch_log_group_mygroup"
}

data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "step_functions_policy_lambda_policy_all_poc_sf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_cw" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}