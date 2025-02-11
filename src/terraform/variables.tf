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
  default = "easyorder-infra/terraform.tfstate"
}

variable "key_cliente_app" {
  default = "easyorder-apps/easyorder-app-cliente.json"
}

variable "key_produto_app" {
  default = "easyorder-apps/easyorder-app-produto.json"
}

variable "key_core_app" {
  default = "easyorder-apps/easyorder-app-core.json"
}


data "terraform_remote_state" "easyorder-infra" {
  backend = "s3"
  config = {
    bucket = var.bucket_infra
    key    = var.key_infra
    region = var.region
  }
}

data "aws_s3_object" "cliente_app_data" {
  bucket = var.bucket_infra
  key    = var.key_cliente_app
}
data "aws_s3_object" "produto_app_data" {
  bucket = var.bucket_infra
  key    = var.key_produto_app
}
data "aws_s3_object" "core_app_data" {
  bucket = var.bucket_infra
  key    = var.key_core_app
}

locals {
  cliente_app_data      = jsondecode(data.aws_s3_object.cliente_app_data.body)
  load_balancer_cliente = local.cliente_app_data.lb_hostname
}

locals {
  produto_app_data      = jsondecode(data.aws_s3_object.produto_app_data.body)
  load_balancer_produto = local.produto_app_data.lb_hostname
}

locals {
  core_app_data      = jsondecode(data.aws_s3_object.core_app_data.body)
  load_balancer_core = local.core_app_data.lb_hostname
}
