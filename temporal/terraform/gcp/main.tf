resource "kubernetes_namespace" "temporal" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "temporal"

      "platform.plural.sh/sync-target" = "pg"

    }
  }
}

