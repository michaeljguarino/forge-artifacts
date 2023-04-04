resource "kubernetes_namespace" "typesense" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name"           = "typesense"
    }
  }
}
