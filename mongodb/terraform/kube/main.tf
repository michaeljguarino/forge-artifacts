resource "kubernetes_namespace" "mongodb" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "mongodb"

    }
  }
}

