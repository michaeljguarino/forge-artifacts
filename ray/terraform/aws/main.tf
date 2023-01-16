resource "kubernetes_namespace" "ray" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "ray"

    }
  }
}

module "single_az_node_groups" {
  count                  = "${var.create_single_az_node_groups ? 1 : 0}"
  source                 = "github.com/pluralsh/module-library//terraform/eks-node-groups/single-az-node-groups?ref=df068595c3e91590d11e1ace11e1d688630f03d6"
  cluster_name           = var.cluster_name
  default_iam_role_arn   = var.node_role_arn
  tags                   = var.tags
  node_groups_defaults   = var.node_groups_defaults

  node_groups            = var.single_az_node_groups
  set_desired_size       = false
  private_subnets        = var.private_subnets
}
