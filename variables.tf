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

variable "app_api_port_server" {
  description = "Port used by api server on container"
}

variable "app_grpc_port_server" {
  description = "Port used by grpc server on container"
}

variable "notifications_email" {
  description = "Email used to notificate users"
}

variable "mongodb_url_notifications" {
  description = ""
  sensitive   = true
}
variable "aws_access_key_id" {
  description = "https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html"
  sensitive   = true
}
variable "aws_secret_access_key" {
  description = "https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html"
  sensitive   = true
}
