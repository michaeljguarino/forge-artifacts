resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "external-secrets"

    }
  }
}

