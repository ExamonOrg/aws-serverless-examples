# https://my-domain.auth.eu-west-1.amazoncognito.com/login?response_type=token&client_id=1vvv1d45bqa3ractsp87c09enn&redirect_uri=https%3A%2F%2Fwww.mytest.com
# https://my-domain.auth.eu-west-1.amazoncognito.com/authorize?client_id=1example23456789&response_type=code&scope=aws.cognito.signin.user.admin+email+openid+profile&redirect_uri=https%3A%2F%2Faws.amazon.com

provider "aws" {
  region = "eu-west-1"
}

resource "aws_cognito_user_pool" "main" {
  name = "my_user_pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_attributes = ["email"]

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 5
      max_length = 50
    }
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "client" {
  name = "my_user_pool_client"

  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = true
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name = "my_identity_pool"

  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "my-domain"
  user_pool_id = aws_cognito_user_pool.main.id
}
