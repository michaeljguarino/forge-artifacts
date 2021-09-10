resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "nextcloud"
    }
  }
}
