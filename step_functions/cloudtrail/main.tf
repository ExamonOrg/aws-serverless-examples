resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-cloud-trail"
  role_arn   = aws_iam_role.example_role.arn
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
  name               = "stepfn-role"
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
