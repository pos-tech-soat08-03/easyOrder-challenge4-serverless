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

data "terraform_remote_state" "easyorder-infra" {
  backend = "s3"
  config = {
    bucket = var.bucket_infra
    key    = var.key_infra
    region = var.region
  }
}

variable "lb_endpoint" {
  type    = string
  default = "http://example.com"
} 