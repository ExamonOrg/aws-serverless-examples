resource "aws_kms_key" "my_kms_key" {
    description             = "My KMS Key"
    deletion_window_in_days = 30
    policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow CreateKey for examon",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::478119378221:user/examon"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
EOF
}

output "kms_key_arn" {
    value = aws_kms_key.my_kms_key.arn
}
