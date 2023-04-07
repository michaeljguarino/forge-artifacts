resource "kubernetes_namespace" "dagster" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "dagster"
      "platform.plural.sh/sync-target" = "pg"
    }
  }
}

module "dagster-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${var.cluster_name}-dagster-sa"
  namespace           = var.namespace
  project_id          = var.project_id
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  k8s_sa_name         = "dagster"
  roles               = ["roles/storage.admin"]
}

module "gcs_buckets" {
  source = "github.com/pluralsh/module-library//terraform/gcs-buckets"

  project_id            = var.project_id
  bucket_names          = [var.dagster_bucket]
  service_account_email = module.dagster-workload-identity.gcp_service_account_email
  location              = var.bucket_location
}

