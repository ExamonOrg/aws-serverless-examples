module "simple_lambda" {
  source        = "./../../../tf-modules/simple_lambda"
  source_dir    = "./handlers/one"
  function_name = "step_fn_lambda_one_catch"
  handler       = "src.main.lambda_handler"
  runtime       = "python3.11"
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-catch-lambda"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      Comment = "A simple Step Functions state machine with a single Lambda task that raises an error."
      StartAt = "Main"
      States  = {
        Main = {
          Type   = "Pass"
          Result = "World"
          Next   = "Call Lambda"
        }
        "Call Lambda" = {
          Type     = "Task"
          Resource = module.simple_lambda.arn
          Next     = "Finished"
          Catch    = [
            {
              ErrorEquals = ["MyException"]
              Next        = "CustomErrorFallback"
            },
            {
              ErrorEquals = ["States.TaskFailed"]
              Next        = "ReservedTypeFallback"
            },
            {
              ErrorEquals = ["States.ALL"]
              Next        = "CatchAllFallback"
            }
          ]
        },
        Finished = {
          Type = "Pass"
          Result = "This is the end"
          End = true
        },
        CustomErrorFallback = {
          Type = "Pass"
          Result = "This is a fallback from a custom Lambda function exception"
          End = true
        },
        ReservedTypeFallback = {
          Type = "Pass"
          Result = "This is a fallback from a reserved error code"
          End = true
        },
        CatchAllFallback = {
          Type = "Pass"
          Result = "This is a fallback from any error code"
          End = true
        }
      }
    })
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-catch-lambda"
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
  name   = "step_functions_policy_lambda_policy_all_poc_sf_catch"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}