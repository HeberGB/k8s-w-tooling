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
#     --policy-name AWSLoadBalancerControllerIAMPolicy \
#     --policy-document file://ingress-iam-policy.json
# Take note of the policy ARN that is returned

# 3. Create a IAM role and ServiceAccount for the AWS Load Balancer controller, use the ARN from the step above
# eksctl create iamserviceaccount \
# --cluster=<cluster-name> \
# --namespace=kube-system \
# --name=aws-load-balancer-controller \
# --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
# --approve

resource "helm_release" "ingress_controller" {
  name = "ingress-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = local.cluster_name
  }
  set {
    name = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
