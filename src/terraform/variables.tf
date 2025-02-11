data "aws_iam_role" "labrole" {
  name = "LabRole"
}

variable "accountIdVoclabs" {
  description = "ID da conta AWS"
}

variable "region" {
  description = "The S3 region to store the Terraform state file"
  default     = "us-east-1"
}

variable "bucket_infra" {
}

variable "key_infra" {
}

variable "key_cliente_app" {
}

variable "key_produto_app" {
}

variable "key_core_app" {
}


data "terraform_remote_state" "easyorder-infra" {
  backend = "s3"
  config = {
    bucket = var.bucket_infra
    key    = var.key_infra
    region = var.region
  }
}

data "aws_s3_bucket_object" "cliente_app_data" {
  bucket = var.bucket_infra
  key    = var.key_cliente_app
}
data "aws_s3_bucket_object" "produto_app_data" {
  bucket = var.bucket_infra
  key    = var.key_produto_app
}
data "aws_s3_bucket_object" "core_app_data" {
  bucket = var.bucket_infra
  key    = var.key_core_app
}

locals {
  cliente_app_data       = jsondecode(data.aws_s3_bucket_object.cliente_app_data.body)
  load_balancer_cliente = local.cliente_app_data.LoadBalancerHostname
  produto_app_data       = jsondecode(data.aws_s3_bucket_object.produto_app_data.body)
  load_balancer_produto = local.produto_app_data.LoadBalancerHostname
  core_app_data       = jsondecode(data.aws_s3_bucket_object.core_app_data.body)
  load_balancer_core = local.core_app_data.LoadBalancerHostname
}

