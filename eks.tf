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
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 2
      instance_type    = "t3.medium"
    }

    backend = {
      name             = "backend"
      desired_capacity = 5
      max_capacity     = 8
      min_capacity     = 3
      instance_type    = "t3.medium"
    }

    frontend = {
      name             = "frontend"
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1
      instance_type    = "t3.medium"
    }

  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
