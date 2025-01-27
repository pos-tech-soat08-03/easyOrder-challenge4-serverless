variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"  # Versão suportada
  instance_class       = "db.t3.micro"  # Classe de instância suportada
  db_name              = "mydb"
  username             = "uadmin"
  password             = "padmin$099"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "vpc_id" {}

output "rds_host" {
  value = aws_db_instance.default.endpoint
}

output "rds_port" {
  value = aws_db_instance.default.port
}

output "rds_username" {
  value = aws_db_instance.default.username
}

output "rds_password" {
  value     = aws_db_instance.default.password
  sensitive = true
}