module "simple_lambda" {
  source        = "./../../../tf-modules/simple_lambda"
  source_dir    = "./handlers/one"
  function_name = "step_fn_lambda_distributed_one"
  handler       = "src.main.lambda_handler"
  runtime       = "python3.11"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "2834acbddatabucket"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "2834acbddataoutputbucket"
}

resource "aws_s3_bucket_object" "terraformtests" {
  depends_on = [aws_s3_bucket.my_bucket]
  bucket     = "2834acbddatabucket"
  key        = "csvDataset/ratings.csv"
  source     = "csvDataset/ratings.csv"
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "state-machine-distributed-map-demo"
  role_arn   = aws_iam_role.example_role.arn
  definition = jsonencode({
    "Comment" = "Using Map state in Distributed mode"
    "StartAt" = "Process data"
    "States"  = {
      "Process data" = {
        "Type"           = "Map"
        "MaxConcurrency" = 100
        "ItemReader"     = {
          "ReaderConfig" = {
            "InputType"         = "CSV"
            "CSVHeaderLocation" = "FIRST_ROW"
          }
          "Resource"   = "arn:aws:states:::s3:getObject"
          "Parameters" = {
            "Bucket" = "2834acbddatabucket"
            "Key"    = "csvDataset/ratings.csv"
          }
        }
        "ItemProcessor" = {
          "ProcessorConfig" = {
            "Mode"          = "DISTRIBUTED"
            "ExecutionType" = "EXPRESS"
          }
          "StartAt" = "Process CSV data"
          "States"  = {
            "Process CSV data" = {
              "Type"       = "Task"
              "Resource"   = "arn:aws:states:::lambda:invoke"
              "OutputPath" = "$.Payload"
              "Parameters" = {
                "Payload.$"    = "$"
                "FunctionName" = "step_fn_lambda_distributed_one"
              }
              "End" = true
            }
          }
        }
        "Label"        = "Processdata"
        "End"          = true
        "ResultWriter" = {
          "Resource"   = "arn:aws:states:::s3:putObject"
          "Parameters" = {
            "Bucket" = "2834acbddataoutputbucket"
            "Prefix" = "resultData"
          }
        },
        "ItemSelector" : {
          "index.$" = "$$.Map.Item.Index"
          "value.$" = "$$.Map.Item.Value"
        }
      }
    }
  })



  #  definition = <<EOF
  #{
  #  "Comment": "Using Map state in Distributed mode",
  #  "StartAt": "Process data",
  #  "States": {
  #    "Process data": {
  #      "Type": "Map",
  #      "MaxConcurrency": 100,
  #      "ItemReader": {
  #        "ReaderConfig": {
  #          "InputType": "CSV",
  #          "CSVHeaderLocation": "FIRST_ROW"
  #        },
  #        "Resource": "arn:aws:states:::s3:getObject",
  #        "Parameters": {
  #          "Bucket": "2834acbddatabucket",
  #          "Key": "csvDataset/ratings.csv"
  #        }
  #      },
  #      "ItemProcessor": {
  #        "ProcessorConfig": {
  #          "Mode": "DISTRIBUTED",
  #          "ExecutionType": "EXPRESS"
  #        },
  #        "StartAt": "Process CSV data",
  #        "States": {
  #          "Process CSV data": {
  #            "Type": "Task",
  #            "Resource": "arn:aws:states:::lambda:invoke",
  #            "OutputPath": "$.Payload",
  #            "Parameters": {
  #              "Payload.$": "$",
  #              "FunctionName": "step_fn_lambda_distributed_one"
  #            },
  #            "End": true
  #          }
  #        }
  #      },
  #      "Label": "Processdata",
  #      "End": true,
  #      "ResultWriter": {
  #        "Resource": "arn:aws:states:::s3:putObject",
  #        "Parameters": {
  #          "Bucket": "2834acbddataoutputbucket",
  #          "Prefix": "resultData"
  #        }
  #      },
  #      "ItemSelector": {
  #        "index.$": "$$.Map.Item.Index",
  #        "value.$": "$$.Map.Item.Value"
  #      }
  #    }
  #  }
  #}
  #
  #  EOF
}

resource "aws_iam_role" "example_role" {
  name               = "stepfn-role-state-machine-distributed-map"
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
      "lambda:*",
      "s3:*",
      "states:StartExecution"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "step_functions_policy_lambda_policy_distributed_all_poc_sf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}