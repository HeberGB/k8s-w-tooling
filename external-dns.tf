##############################
# REQUIREMENTS TO APPLY THIS #
##############################
#
# 1. Create IAM OIDC provider
# eksctl utils associate-iam-oidc-provider \
#     --region <region-code> \
#     --cluster <your-cluster-name> \
#     --approve

# 2. Create an IAM policy called AWSLoadBalancerControllerIAMPolicy
# aws iam create-policy \                                                                           
#     --policy-name AllowExternalDNSUpdates \                                           
#     --policy-document file://external-dns-iam-policy.json
# Take note of the policy ARN that is returned

# 3. Create a IAM role and ServiceAccount for the AWS Load Balancer controller, use the ARN from the step above
# eksctl create iamserviceaccount \  
# --cluster=eks-zeb-development \
# --namespace=kube-system \
# --name=external-dns \
# --attach-policy-arn=iam::<AWS_ACCOUNT_ID>:policy/AllowExternalDNSUpdates \
# --approve

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["endpoints", "pods", "services"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"

    labels = {
      "app.kubernetes.io/instance" = "external-dns"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }

  depends_on = [kubernetes_cluster_role.external_dns]
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }
  depends_on = [kubernetes_cluster_role_binding.external_dns_viewer]

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }

      spec {
        container {
          name  = "external-dns"
          image = "k8s.gcr.io/external-dns/external-dns:v0.7.4"
          args  = ["--source=service", "--source=ingress", "--provider=aws", "--aws-zone-type=public", "--registry=txt", "--txt-owner-id=external-dns"]

          resources {
            limits {
              cpu    = "250m"
              memory = "500Mi"
            }

            requests {
              cpu    = "250m"
              memory = "500Mi"
            }
          }
        }
        service_account_name            = "external-dns"
        automount_service_account_token = true

        security_context {
          fs_group = 1000
        }
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

