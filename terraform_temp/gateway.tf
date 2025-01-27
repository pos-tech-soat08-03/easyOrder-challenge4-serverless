
resource "aws_api_gateway_rest_api" "cpf_api" {
  name        = "EasyOrder-ApiGateway-CPFValidation"
  description = "API Gateway para validar CPF"
}

resource "aws_api_gateway_resource" "cpf_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.cpf_api.id
  parent_id   = aws_api_gateway_rest_api.cpf_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "cpf_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.cpf_api.id
  resource_id   = aws_api_gateway_resource.cpf_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cpf_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cpf_api.id
  resource_id             = aws_api_gateway_resource.cpf_proxy_resource.id
  http_method             = aws_api_gateway_method.cpf_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cpf_lookup.invoke_arn
  depends_on              = [
    aws_api_gateway_method.cpf_proxy_method,
  ]
}

resource "aws_api_gateway_deployment" "cpf_deployment" {
  depends_on = [aws_api_gateway_integration.cpf_proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.cpf_api.id

  lifecycle {
    create_before_destroy = true
  }
  
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.cpf_proxy_integration))
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.cpf_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.cpf_api.id
  stage_name    = "PRODUCTION"
  depends_on    = [aws_api_gateway_deployment.cpf_deployment]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_lookup.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.cpf_api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.cpf_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod_stage.stage_name}/${aws_lambda_function.cpf_lookup.function_name}"
}