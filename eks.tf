module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = terraform.workspace
  }

  vpc_id = module.vpc.vpc_id

  node_groups = {
    tools = {
      name             = "tools"
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }

    admin = {
      name             = "admin"
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
}

resource "aws_iam_policy" "allow_ecr_on_node_groups" {
  name        = "AllowEcrOnNodeGroups"
  description = "Policy that allows pull images from ECR repositories"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_ecr_on_node_groups" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.allow_ecr_on_node_groups.arn
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
