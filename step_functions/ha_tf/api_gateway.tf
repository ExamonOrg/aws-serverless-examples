resource "aws_api_gateway_rest_api" "default" {
  name        = "Terraform Human approval endpoint"
  description = "HTTP Endpoint backed by API Gateway and Lambda"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/execution" = {
        get = {
          x-amazon-apigateway-integration = {
            "type" = "aws_proxy"
            "httpMethod" = "POST"
            "uri" = "arn:aws:apigateway:${data.aws_region.current.id}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:function:${"step_fn_approval_tf2"}/invocations"
            "passthroughBehavior" = "never"
          }
        }
      }
    }
  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  triggers    = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.default.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = "states"
}

resource "aws_lambda_permission" "permission_1" {
  statement_id  = "AllowExecutionFromRestAPI_${var.step_fn_approval_name}"
  action        = "lambda:InvokeFunction"
  function_name = "step_fn_approval_tf2"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/*"
}
