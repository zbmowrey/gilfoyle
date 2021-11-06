provider "aws" {
  region  = "us-east-1"
  profile = terraform.workspace
  default_tags {
    tags = {
      Owner       = var.owner
      CostCenter  = var.cost-center
      Application = var.app-name
      Environment = terraform.workspace
      Terraform   = true
    }
  }
}

# If we change these parameter names, we also need to update lambda-insults/handle.py
# so it can find the new parameters.

resource "aws_ssm_parameter" "insults-table" {
  name  = "insults-lambda-table"
  type  = "String"
  value = var.insults-store
}

# Holds our iterator and our messages list.

data "aws_dynamodb_table" "insults-store" {
  name = var.insults-store
}

resource "aws_dynamodb_table_item" "insults-slack-url" {
    table_name = data.aws_dynamodb_table.insults-store.name
    hash_key = "k"

    item = <<EOF
{
    "k": { "S": "insults#slack" },
    "v": { "S": "${var.insults-url}" }
}
EOF
}

resource "aws_cloudwatch_log_group" "insults" {
  name = "${var.app-name}-${terraform.workspace}-logs"
}

resource "aws_lambda_permission" "insults" {
  statement_id  = "AllowInsultsBotLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.insults-lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.insults-api.apigatewayv2_api_execution_arn}/*/*/*"
}

module "insults-lambda" {
  source                   = "terraform-aws-modules/lambda/aws"
  function_name            = "${var.app-name}-${terraform.workspace}"
  description              = "Responds to Slash Commands with an Insult."
  handler                  = "handle.handle"
  runtime                  = "python3.8"
  publish                  = false
  source_path              = "lambda-insults/"
  environment_variables    = {
    Serverless = "Terraform"
  }
  attach_policy_statements = true
  policy_statements        = {
    dynamodb = {
      effect    = "Allow",
      actions   = [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      resources = [data.aws_dynamodb_table.insults-store.arn]
    }
  }
  attach_policy_json       = true
  policy_json              = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": ["${aws_ssm_parameter.insults-table.arn}"]
        }
    ]
}
EOF
}

module "insults-api" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.app-name}-${terraform.workspace}"
  description   = "API Gateway for insults Slack Bot"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = [
      "content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"
    ]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.insults.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /" = {
      lambda_arn             = module.insults-lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = module.insults-lambda.lambda_function_arn
    }
  }
}