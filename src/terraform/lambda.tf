
resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./lambda_function"
  output_path = "./lambda_function.zip"
}

resource "aws_lambda_function" "cpf_lookup" {
  function_name    = "cpf_lookup"
  runtime          = "python3.8"
  role             = data.aws_iam_role.labrole.arn
  handler          = "lambda_function.lambda_handler"
  filename         = archive_file.lambda_zip.output_path
  depends_on       = [archive_file.lambda_zip]
  source_code_hash = filebase64sha256(archive_file.lambda_zip.output_path)
  publish          = true
  timeout          = 10
  memory_size      = 128
  vpc_config {
    subnet_ids         = data.terraform_remote_state.easyorder-infra.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.easyorder-infra.outputs.security_group_id]
  }
  environment {
    variables = {
      RDS_HOST     = data.terraform_remote_state.easyorder-database.outputs.rds_instance_address
      RDS_USERNAME = data.terraform_remote_state.easyorder-database.outputs.rds_username
      RDS_PASSWORD = data.terraform_remote_state.easyorder-database.outputs.rds_password
      RDS_DB_NAME  = data.terraform_remote_state.easyorder-database.outputs.rds_db_name
    }
  }
}
