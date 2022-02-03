data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

module "vpc" {
  source                 = "github.com/pluralsh/terraform-aws-vpc?ref=worker_subnet"
  name                   = var.vpc_name
  cidr                   = "10.0.0.0/16"
  azs                    = data.aws_availability_zones.available.names
  public_subnets         = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  worker_private_subnets = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
  enable_dns_hostnames   = true
  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  worker_private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

data "aws_servicequotas_service_quota" "managed_node_groups" {
  quota_code   = "L-6D54EA21"
  service_code = "eks"
}

data "aws_servicequotas_service_quota" "auto_scaling_groups" {
  quota_code   = "L-CDE20ADC"
  service_code = "autoscaling"
}

resource "aws_servicequotas_service_quota" "managed_node_groups" {
  count = data.aws_servicequotas_service_quota.managed_node_groups.value < var.max_managed_node_groups ? 1 : 0
  quota_code   = "L-6D54EA21"
  service_code = "eks"
  value        = var.max_managed_node_groups
}

resource "aws_servicequotas_service_quota" "auto_scaling_groups" {
  count = data.aws_servicequotas_service_quota.auto_scaling_groups.value < var.max_auto_scaling_groups ? 1 : 0
  quota_code   = "L-CDE20ADC"
  service_code = "autoscaling"
  value        = var.max_auto_scaling_groups
}

module "cluster" {
  source          = "github.com/pluralsh/terraform-aws-eks?ref=asg-azs"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  private_subnets = module.vpc.private_subnets_ids
  public_subnets  = module.vpc.public_subnets_ids
  worker_private_subnets = module.vpc.worker_private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  write_kubeconfig = false

  node_groups_defaults = {
    desired_capacity = var.desired_capacity
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity

    instance_types = var.instance_types
    disk_size = 50
    subnets = module.vpc.worker_private_subnets
    ami_release_version = "1.21.5-20220123"
    force_update_version = true
    ami_type = "AL2_x86_64"
    k8s_labels = {}
    k8s_taints = []
  }

  node_groups = merge(var.base_node_groups, var.node_groups)

  map_users = var.map_users
  map_roles = concat(var.map_roles, var.manual_roles)

  depends_on = [
    aws_servicequotas_service_quota.managed_node_groups
  ]
}

# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = module.cluster.cluster_id
#   addon_name   = "vpc-cni"
#   addon_version     = "v1.10.1-eksbuild.1"
#   resolve_conflicts = "OVERWRITE"
#   tags = {
#       "eks_addon" = "vpc-cni"
#   }
#   depends_on = [
#     module.cluster.node_groups
#   ]
# }

resource "aws_eks_addon" "core_dns" {
  cluster_name      = module.cluster.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.8.4-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  tags = {
      "eks_addon" = "coredns"
  }
  depends_on = [
    module.cluster.node_groups,
    helm_release.cilium
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.cluster.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = "v1.21.2-eksbuild.2"
  resolve_conflicts = "OVERWRITE"
  tags = {
      "eks_addon" = "kube-proxy"
  }
  depends_on = [
    module.cluster.node_groups
  ]
}

resource "kubernetes_namespace" "bootstrap" {
  metadata {
    name = "bootstrap"
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "bootstrap"
    }
  }

  depends_on = [
    module.cluster.cluster_id
  ]
}
