resource "aws_iam_policy" "step_functions_policy_success_failure" {
  name   = "state-machine-send-success-failure-tf"
  policy = data.aws_iam_policy_document.sfn_success_failure.json
}

data "aws_iam_policy_document" "sfn_success_failure" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "states:SendTaskSuccess",
      "states:SendTaskFailure",
    ]
    resources = [
      "*",
    ]
  }
}

output "step_functions_policy_success_failure_arn" {
  value = aws_iam_policy.step_functions_policy_success_failure.arn
}