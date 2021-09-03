resource "kubernetes_namespace" "etcd" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "etcd"
    }
  }
}
