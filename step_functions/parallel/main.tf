#https://docs.aws.amazon.com/step-functions/latest/dg/amazon-states-language-parallel-state.html

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-parallel-lambda"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      "Comment" = "Parallel Example."
      "StartAt" = "TheBeginning"
      "States"  = {
        "TheBeginning" = {
          "Type"     = "Parallel"
          "End"      = true
          "Branches" = [
            {
              "StartAt" = "Hello"
              "States"  = {
                "Hello" = {
                  "Type"   = "Pass"
                  "Result" = "Hello"
                  "End"    = true
                }
              }
            },
            {
              "StartAt" = "World"
              "States"  = {
                "World" = {
                  "Type"   = "Pass"
                  "Result" = "World"
                  "End" : true
                }
              }
            }
          ]
        }
      }
    }
  )
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-parallel"
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
