module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "techchallenge2-eks"
  kubernetes_version = "1.33"

  endpoint_public_access  = true
  endpoint_private_access = true

  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    terraform_admin = {
      principal_arn = "arn:aws:iam::258083582548:user/Kubernetes-Admin"

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }

  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    techchallenge2_nodes = {
      name = "tech-node-group"

      instance_types = ["t3.small"]

      min_size     = 1
      desired_size = 1
      max_size     = 4
    }
  }

  tags = {
    Project = "TechChallenge2"
  }
}