resource "kubernetes_namespace" "csgo" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "csgo"

    }
  }
}

