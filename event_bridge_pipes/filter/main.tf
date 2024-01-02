data "aws_caller_identity" "main" {}

resource "aws_iam_role" "pipes" {
  assume_role_policy = jsonencode({
    Version     = "2012-10-17"
    Statement = {
      Effect    = "Allow"
      Action    = ["sts:AssumeRole"]
      Principal = {
        Service = "pipes.amazonaws.com"
      }
    }
  })
}
