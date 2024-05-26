locals {
  env = "Assessment-section-terraform"
  common_tags = {
    Name    = "Assessment Section 2 Priyanka"
    Creator = "priyankatuladhar@lftechnology.com"
    Project = "Post Internship Training"
    Task    = "Terraform"
  }
}

# resource "" "name" {
#   tags = {
#     Name = "${local.envi}-try1"
#   }
# }
resource "aws_cognito_user_pool" "userpool" {
  name = "mypool_pri"

  schema {
    name                     = "Email"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 10
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_attributes = ["email"]
  username_configuration {
    case_sensitive = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  tags = local.common_tags
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name         = "my-client-cognito-priyanka"
  user_pool_id = aws_cognito_user_pool.userpool.id

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  "ALLOW_USER_PASSWORD_AUTH"]

  generate_secret               = false
  prevent_user_existence_errors = "LEGACY"
  refresh_token_validity        = 1
  access_token_validity         = 1
  id_token_validity             = 1
  #do we wanna get it be identified by mins, hr, or what what
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "hours"
  }

}

resource "aws_amplify_app" "amplifyapp" {
  name         = "pri-example"
  repository   = "https://github.com/priyankatuladhar/Priyanka-React-CURD"
  access_token = "PAT here"
  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
  
  enable_basic_auth = true
  
  
  
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV          = "test"
    USER_POOL_ID = aws_cognito_user_pool.userpool.id
  }
  
}

resource "aws_amplify_branch" "branch" {
  app_id      = aws_amplify_app.amplifyapp.id
  branch_name = "main"
  framework   = "React"
}


