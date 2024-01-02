module "simple_lambda" {
  source        = "./../../../tf-modules/simple_lambda"
  source_dir    = "./handlers/one"
  function_name = "step_fn_lambda_one_iterator"
  handler       = "src.main.handler"
  runtime       = "python3.11"
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-catch-iterator"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      "Comment" = "Iterator State Machine Example"
      "StartAt" = "ConfigureCount"
      "States"  = {
        "ConfigureCount" = {
          "Type"   = "Pass"
          "Result" = {
            "count" = 10
            "index" = 0
            "step"  = 1
          }
          "ResultPath" = "$.iterator",
          "Next"       = "Iterator"
        }
        "Iterator" = {
          "Type"       = "Task"
          "Resource"   = module.simple_lambda.arn
          "ResultPath" = "$.iterator"
          "Next"       = "IsCountReached"
        }
        "IsCountReached" = {
          "Type" : "Choice"
          "Choices" = [
            {
              "Variable"      = "$.iterator.continue"
              "BooleanEquals" = true
              "Next"          = "ExampleWork"
            }
          ]
          "Default" = "Done"
        }
        "ExampleWork" = {
          "Comment" = "Your application logic, to run a specific number of times"
          "Type"    = "Pass"
          "Result"  = {
            "success" = true
          }
          "ResultPath" = "$.result"
          "Next"       = "Iterator"
        }
        "Done" = {
          "Type" = "Pass"
          "End"  = true
        }
      }
    }
  )
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-iterator-lambda"
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
  name   = "step_functions_policy_lambda_policy_all_poc_sf_iterator"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}