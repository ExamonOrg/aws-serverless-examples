resource "aws_iam_policy" "step_functions_policy_success_failure" {
  name   = "state-machine-send-success-failure-tf"
  policy = data.aws_iam_policy_document.sfn_success_failure.json
}

data "aws_iam_policy_document" "sfn_success_failure" {
  statement {
    sid     = "1"
    effect  = "Allow"
    actions = [
      "states:SendTaskSuccess",
      "states:SendTaskFailure",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "sfn_test_state_role" {
  name = "sfnteststaterole"

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


resource "aws_iam_role_policy" "sfn_test_state" {
  role   = aws_iam_role.sfn_test_state_role.id
  policy = jsonencode({
    "Version"   = "2012-10-17"
    "Statement" = [
      {
        Sid    = "sfnteststatepolicy223"
        Effect = "Allow"
        Action = [
          "states:TestState",
          "states:RevealSecrets",
          "iam:PassRole",
          "lambda:*"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}


output "step_functions_policy_success_failure_arn" {
  value = aws_iam_policy.step_functions_policy_success_failure.arn
}


output "step_functions_policy_test_state_arn" {
  value = aws_iam_role.sfn_test_state_role.arn
}