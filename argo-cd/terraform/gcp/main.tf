resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "argo-cd"
    }
  }
}
