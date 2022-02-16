output "insults-api-invoke-url" {
  description = "Insults Lambda Invocation URL"
  value = module.insults-api.default_apigatewayv2_stage_invoke_url
}
