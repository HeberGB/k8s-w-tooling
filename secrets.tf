resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = "admin"
  }

  data = {
    "url_notifications" = var.mongodb_url_notifications
  }
}

resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws"
    namespace = "admin"
  }

  data = {
    "access_key_id"     = var.aws_access_key_id
    "secret_access_key" = var.aws_secret_access_key
    "region"            = var.region
  }
}
