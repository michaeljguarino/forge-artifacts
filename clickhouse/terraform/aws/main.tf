resource "kubernetes_namespace" "clickhouse" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "clickhouse"

    }
  }
}

