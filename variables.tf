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

variable "github_client_id" {
  description = "Github client id to oauth"
}

variable "github_client_secret" {
  description = "Github client secret to oauth"
}

variable "github_allowed_organizations" {
  description = "Github allowed organizations to oauth"
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
