variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "brand" {
  description = "Brand or company name"
}

variable "aws_ssl_cert_arn" {
  description = "AWS SSL Cert ARN to identify it"
  sensitive   = true
}

variable "smtp_host" {
  description = "SMTP host with port to send emails"
}


variable "smtp_user" {
  description = "SMTP email address to send emails"
}

variable "smtp_password" {
  description = "SMTP password to send emails"
}
