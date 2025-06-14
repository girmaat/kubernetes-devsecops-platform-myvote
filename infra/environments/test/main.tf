provider "aws" {
  region = var.region
}

module "vpc" {
  source       = "../../modules/vpc"
  cluster_name = var.cluster_name
  region       = var.region
  azs          = var.availability_zones
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnet_ids
}

module "eks_nodes" {
  source           = "../../modules/eks-node-group"
  cluster_name     = var.cluster_name
  subnet_ids       = module.vpc.private_subnet_ids
  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  key_name         = var.key_name
  node_role_arn    = var.node_role_arn

  depends_on = [module.eks]
}
