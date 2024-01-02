data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "make_s3_object" {
  source             = "./../../../tf-modules/simple_lambda"
  source_dir         = "./handlers/make_s3_object"
  function_name      = "step_fn_make_s3_object"
  output_path        = "step_fn_make_s3_object.zip"
  handler            = "src.main.lambda_handler"
  runtime            = "python3.11"
  policy_attachments = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  env = {
    BUCKET_NAME = aws_s3_bucket.example.bucket
  }
}

module "decorate_s3_object" {
  source             = "./../../../tf-modules/simple_lambda"
  source_dir         = "./handlers/decorate_s3_object"
  function_name      = "step_fn_decorate_s3_object"
  output_path        = "step_fn_decorate_s3_object.zip"
  handler            = "src.main.lambda_handler"
  runtime            = "python3.11"
  policy_attachments = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  env = {
    BUCKET_NAME = aws_s3_bucket.example.bucket
  }
}

module "finalize_s3_object" {
  source             = "./../../../tf-modules/simple_lambda"
  source_dir         = "./handlers/finalize_s3_object"
  function_name      = "step_fn_finalize_s3_object"
  output_path        = "step_fn_finalize_s3_object.zip"
  handler            = "src.main.lambda_handler"
  runtime            = "python3.11"
  policy_attachments = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  env = {
    BUCKET_NAME = aws_s3_bucket.example.bucket
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "009988yytt-my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-s3-object"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode(
    {
      Comment = "A simple Step Functions state machine with a single Lambda task."
      StartAt = "Make S3 Object"
      States  = {
        "Make S3 Object" = {
          Type     = "Task"
          Resource = module.make_s3_object.arn
          Next     = "Decorate S3 Object"
        }
        "Decorate S3 Object" = {
          Type     = "Task"
          Resource = module.decorate_s3_object.arn
          Next     = "Finalize S3 Object"
        }
        "Finalize S3 Object" = {
          Type     = "Task"
          Resource = module.finalize_s3_object.arn
          End      = true
        }
      }
    })
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role--s3-object-lambda"
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
  name   = "step_functions_policy_s3_chain"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}