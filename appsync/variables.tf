# This should be whatever AWS credentials profile you want to use to publish
# your AppSync service.
variable "aws_credentials_profile" {
  default = "default"
}

# This is the region the service will be built in. Set this to a valid AWS
# region.
variable "region" {
  default = "eu-west-1"
}

variable "prefix" {
  default = "appsync_terraform_go_example"
}
