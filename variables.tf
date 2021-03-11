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
  sensitive   = true
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

variable "postgresql_auth_root_password" {
  sensitive   = true
  description = "Root password for auth microservice database"
}

variable "postgresql_auth_username" {
  sensitive   = true
  description = "Username for auth microservice database"
}

variable "postgresql_auth_database" {
  sensitive   = true
  description = "Database name for auth microservice database"
}

variable "postgresql_auth_password" {
  sensitive   = true
  description = "Password for auth microservice database"
}

variable "postgresql_auth_replication_password" {
  sensitive   = true
  description = "Password for auth microservice database of replication deployment"
}

variable "auth_jwt_secret" {
  sensitive = true
}

variable "auth_app_token_sign" {
  sensitive = true
}

variable "auth_app_token_ttl" {
  sensitive = true
}

variable "auth_app_refresh_token_length" {
  sensitive = true
}

variable "auth_app_refresh_token_ttl" {
  sensitive = true
}

variable "auth_random_password_length" {
  sensitive = true
}

variable "auth_random_pin_length" {
  sensitive = true
}

variable "auth_login_retries" {
  sensitive = true
}

variable "typeorm_connection" {
  sensitive = true
}

variable "typeorm_entities" {
  sensitive = true
}

variable "typeorm_migrations" {
  sensitive = true
}

variable "typeorm_migrations_dir" {
  sensitive = true
}

variable "redis_auth_host_password" {
  sensitive = true
}

variable "redis_auth_port" {
  sensitive = true
}

variable "redis_auth_password" {
  sensitive = true
}

variable "postgresql_clients_username" {
  sensitive   = true
  description = "Username for clients microservice database"
}

variable "postgresql_clients_database" {
  sensitive   = true
  description = "Database name for clients microservice database"
}

variable "postgresql_clients_password" {
  sensitive   = true
  description = "Password for clients microservice database"
}
