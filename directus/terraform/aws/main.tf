resource "kubernetes_namespace" "directus" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by"   = "plural"
      "app.plural.sh/name"             = "directus"
      "platform.plural.sh/sync-target" = "pg"
    }
  }
}


data "aws_iam_role" "postgres" {
  name = "${var.cluster_name}-postgres"
}

resource "kubernetes_service_account" "postgres" {
  metadata {
    name      = "postgres-pod"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.postgres.arn
    }
  }

  depends_on = [
    kubernetes_namespace.directus
  ]
}
