resource "aws_kms_key" "my_kms_key" {
  description             = "My KMS Key"
  deletion_window_in_days = 30
  policy                  = jsonencode({
    Version = "2012-10-17",
    Statement = [{
        Sid = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::478119378221:user/examon"
        },
        Action = "kms:*",
        Resource = "*"
      }]
  })

}


resource "aws_sns_topic" "user_updates" {
  name              = "user-updates-topic"
  kms_master_key_id = aws_kms_key.my_kms_key.arn
}