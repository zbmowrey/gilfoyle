terraform {
  backend "remote" {
    organization = var.organization
    workspaces {
      prefix = var.workspace
    }
  }
  required_providers {
    aws    = ">= 2.67"
    random = ">= 2"
  }
  required_version = ">= 1.0.3"
}

provider "aws" {
  region  = "us-east-1"
  profile = terraform.workspace
  default_tags {
    tags = {
      CostCenter  = var.cost-center
      Owner       = var.owner
      Environment = terraform.workspace
      Terraform   = true
    }
  }
}

# Holds our iterator, our Slack URL, and our messages list.

resource "aws_dynamodb_table" "global-store" {
  provider = aws.secondary
  hash_key = "k"
  name     = "GlobalStore"
  attribute {
    name = "k"
    type = "S"
  }
  ttl {
    attribute_name = "ExpiresAt"
    enabled = true
  }
  tags = {
    CostCenter = "zbmowrey-global"
  }
  billing_mode = "PAY_PER_REQUEST"
}

resource "aws_cloudwatch_log_group" "gilfoyle" {
  provider = aws.secondary
  name = "${var.app-name}-${terraform.workspace}-gilfoyle-logs"
}

resource "aws_lambda_permission" "gilfoyle" {
  statement_id  = "AllowGilfoyleLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.gilfoyle-lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.gilfoyle-api.apigatewayv2_api_execution_arn}/*/*/*"
}

module "gilfoyle-lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "${var.app-name}-${terraform.workspace}-gilfoyle"
  description   = "Provides a webhook for Slack user impersonation."
  handler       = "handle.handle"
  runtime       = "python3.8"
  publish       = false
  source_path   = "lambda-gilfoyle/"
  environment_variables = {
    Serverless = "Terraform"
  }
  tags = {
    CostCenter = "lambda-gilfoyle"
  }
  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = [
         "dynamodb:GetItem",
         "dynamodb:Query",
         "dynamodb:UpdateItem"
      ],
      resources = [aws_dynamodb_table.global-store.arn]
    }
  }
}

module "gilfoyle-api" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.app-name}-${terraform.workspace}"
  description   = "API Gateway for Gilfoyle Slack Bot"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.gilfoyle.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /" = {
      lambda_arn             = module.gilfoyle-lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = module.gilfoyle-lambda.lambda_function_arn
    }
  }
  tags = {
    Module = "lambda-web-mail"
    Name = "web-mail-api"
  }
}