resource "kubernetes_namespace" "dagster" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "dagster"
      "platform.plural.sh/sync-target" = "pg"
    }
  }
}

module "s3_buckets" {
  source = "github.com/pluralsh/module-library//terraform/s3-buckets"
  bucket_names = [var.dagster_bucket]
  policy_prefix = "dagster"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

