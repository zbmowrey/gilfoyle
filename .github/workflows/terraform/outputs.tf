output "gilfoyle-api-invoke-url" {
  description = "Gilfoyle Lambda Invocation URL"
  value = module.gilfoyle-api.default_apigatewayv2_stage_invoke_url
}
