resource "aws_cloudtrail" "example" {
  depends_on = [aws_s3_bucket_policy.example]

  name                          = "example"
  s3_bucket_name                = aws_s3_bucket.example.id
  include_global_service_events = false
  event_selector {
    read_write_type          = "WriteOnly"
    include_management_events = true
  }
}
