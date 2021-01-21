resource "aws_eks_node_group" "tools" {
  cluster_name    = local.cluster_name
  node_group_name = "tools"
  node_role_arn   = aws_iam_role.ng_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    module.eks,
  ]
}

resource "aws_eks_node_group" "backend" {
  cluster_name    = local.cluster_name
  node_group_name = "backend"
  node_role_arn   = aws_iam_role.ng_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 5
    max_size     = 8
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    module.eks,
  ]
}

resource "aws_eks_node_group" "frontend" {
  cluster_name    = local.cluster_name
  node_group_name = "frontend"
  node_role_arn   = aws_iam_role.ng_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    module.eks,
  ]
}
