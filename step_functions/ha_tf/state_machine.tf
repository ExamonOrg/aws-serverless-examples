resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-human-approval-tf"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      "StartAt" = "Lambda Callback"
      "TimeoutSeconds" : 3600
      "States"  = {
        "Lambda Callback" = {
          "Type"       = "Task"
          "Resource"   = "arn:aws:states:::lambda:invoke.waitForTaskToken"
          "Parameters" = {
            "FunctionName" = module.step_fn_send_email_tf.arn
            "Payload"      = {
              "ExecutionContext.$" = "$$"
              "APIGatewayEndpoint" = "${aws_api_gateway_deployment.default.invoke_url}states"
            }
          }
          "Next" = "ManualApprovalChoiceState"
        }
        "ManualApprovalChoiceState" = {
          "Type"    = "Choice"
          "Choices" = [
            {
              "Variable"     = "$.Status"
              "StringEquals" = "Approved!"
              "Next"         = "ApprovedPassState"
            },
            {
              "Variable"     = "$.Status"
              "StringEquals" = "Rejected!"
              "Next"         = "RejectedPassState"
            }
          ]
        }
        "ApprovedPassState" = {
          "Type" = "Pass"
          "End"  = true
        }
        "RejectedPassState" : {
          "Type" = "Pass"
          "End"  = true
        }
      }
    }
  )
}

resource "aws_iam_role" "example_role" {
  name               = "state-machine-human-approval-role-tf"
  assume_role_policy = jsonencode(
    {
      Version   = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = {
            Service = "states.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
}

data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "state-machine-human-approval-policy-tf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}