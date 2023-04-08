resource "kubernetes_namespace" "weaviate" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name"           = "weaviate"
    }
  }
}

