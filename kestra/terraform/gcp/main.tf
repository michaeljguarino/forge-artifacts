resource "kubernetes_namespace" "kestra" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "kestra"

      "platform.plural.sh/sync-target" = "pg"

    }
  }
}

