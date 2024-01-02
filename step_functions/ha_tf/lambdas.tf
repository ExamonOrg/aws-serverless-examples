module "step_fn_approval_tf" {
  source        = "./../../../tf-modules/simple_lambda"
  source_dir    = "./handlers/approval"
  function_name = var.step_fn_approval_name
  handler       = "main.handler"
  runtime       = "nodejs18.x"
  output_path   = "step_fn_approval_tf2.zip"
  policy_attachments = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    var.step_fn_approval_arn
  ]

}

module "step_fn_send_email_tf" {
  source             = "./../../../tf-modules/simple_lambda"
  source_dir         = "./handlers/send_email"
  function_name      = "step_fn_send_email_tf2"
  handler            = "main.handler"
  runtime            = "nodejs18.x"
  output_path        = "step_fn_send_email_tf2.zip"
  policy_attachments = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ]
  env = {
    "EMAIL_TOPIC_ARN" = aws_sns_topic.user_updates.arn
  }
}
