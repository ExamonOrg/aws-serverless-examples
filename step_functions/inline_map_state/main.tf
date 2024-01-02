#https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-use-inline-map.html

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-map-demo"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      Comment = "Using Map state in Inline mode"
      StartAt = "Pass"
      States  = {
        Pass = {
          Type   = "Pass"
          Next   = "Map demo"
          Result = {
            foo    = "bar"
            colors = [
              "red",
              "green",
              "blue",
              "yellow",
              "white"
            ]
          }
        },
        "Map demo" = {
          Type          = "Map"
          ItemsPath     = "$.colors"
          ItemProcessor = {
            ProcessorConfig = {
              Mode = "INLINE"
            }
            StartAt = "Generate UUID"
            States  = {
              "Generate UUID" = {
                Type       = "Pass"
                End        = true
                Parameters = {
                  "uuid.$" = "States.UUID()"
                }
                OutputPath = "$.uuid"
              }
            }
          },
          "End" = true
        }
      }
    }
  )
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-map"
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
#
#data "aws_iam_policy_document" "lambda_access_policy" {
#  statement {
#    actions = [
#      "lambda:*"
#    ]
#    resources = ["*"]
#  }
#}
#
#resource "aws_iam_policy" "step_functions_policy_lambda" {
#  name   = "step_functions_policy_lambda_policy_all_poc_sf_catch"
#  policy = data.aws_iam_policy_document.lambda_access_policy.json
#}
#
#resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
#  role       = aws_iam_role.example_role.name
#  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
#}