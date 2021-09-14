resource "kubernetes_namespace" "argo-workflows" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "argo-workflows"
    }
  }
}
