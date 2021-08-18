resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name = var.vpc_subnetwork_name

  ip_cidr_range = var.vpc_subnetwork_cidr_range

  network = google_compute_network.vpc_network.name

  secondary_ip_range {
    range_name    = local.pods_cidr_name
    ip_cidr_range = var.cluster_secondary_range_cidr
  }

  secondary_ip_range {
    range_name    = local.services_cidr_name
    ip_cidr_range = var.services_secondary_range_cidr
  }

  private_ip_google_access = true

  depends_on = [
    google_compute_network.vpc_network,
  ]
}

module "gke" {
  source                     = "github.com/pluralsh/terraform-google-kubernetes-engine?ref=rm-k8s-provider"
  project_id                 = var.gcp_project_id
  name                       = var.cluster_name
  region                     = local.gcp_region
  network                    = google_compute_network.vpc_network.name
  subnetwork                 = google_compute_subnetwork.vpc_subnetwork.name
  ip_range_pods              = local.pods_cidr_name
  ip_range_services          = local.services_cidr_name
  horizontal_pod_autoscaling = true
  http_load_balancing        = true
  remove_default_node_pool   = true
  add_cluster_firewall_rules = true
  network_policy             = true

  node_pools = var.node_pools

  depends_on = [google_compute_subnetwork.vpc_subnetwork]
}

resource "kubernetes_namespace" "bootstrap" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "bootstrap"
    }
  }

  depends_on = [module.gke.endpoint]
}

module "externaldns-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${var.cluster_name}-externaldns"
  namespace           = var.namespace
  project_id          = var.gcp_project_id
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  k8s_sa_name         = "external-dns"
  roles               = ["roles/dns.admin"]
}

resource "kubernetes_service_account" "externaldns" {
  metadata {
    name      = "external-dns"
    namespace = var.namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = module.externaldns-workload-identity.gcp_service_account_email
    }
  }

  depends_on = [kubernetes_namespace.bootstrap]
}

module "certmanager-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${var.cluster_name}-certmanager"
  namespace           = var.namespace
  project_id          = var.gcp_project_id
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  k8s_sa_name         = "certmanager"
  roles               = ["roles/dns.admin"]
}

resource "kubernetes_service_account" "certmanager" {
  metadata {
    name      = "certmanager"
    namespace = var.namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = module.certmanager-workload-identity.gcp_service_account_email
    }
  }

  depends_on = [kubernetes_namespace.bootstrap]
}