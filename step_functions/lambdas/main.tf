module "simple_lambda" {
  source        = "./../../../tf-modules/simple_lambda"
  source_dir    = "./handlers/one"
  function_name = "step_fn_lambda_one"
  handler       = "src.main.lambda_handler"
  runtime       = "python3.11"
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-lambda"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      Comment = "A simple Step Functions state machine with a single Lambda task."
      StartAt = "Hello"
      States  = {
        Hello = {
          Type   = "Pass"
          Result = "Hello"
          Next   = "World"
        }
        World = {
          Type   = "Pass"
          Result = "World"
          Next   = "Call Lambda"
        }
        "Call Lambda" = {
          Type     = "Task"
          Resource = module.simple_lambda.arn
          Next     = "IsNumberEven"
        }
        IsNumberEven = {
          Type    = "Choice"
          Choices = [
            {
              Variable      = "$.is_even"
              BooleanEquals = true
              Next          = "Even"
            }
          ]
          Default = "Odd"
        },
        Even = {
          Type   = "Pass"
          Result = "Even"
          "End" : true
        }
        Odd = {
          Type   = "Pass"
          Result = "Even"
          End    = true
        }
      }
    })
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-lambda"
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
  name   = "step_functions_policy_lambda_policy_all_poc_sf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}