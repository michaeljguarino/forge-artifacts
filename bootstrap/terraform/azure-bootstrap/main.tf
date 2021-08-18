data "azurerm_resource_group" "group" {
  name = var.resource_group
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = data.azurerm_resource_group.group.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = [var.subnet_name]
}

module "aks" {
  source                           = "github.com/pluralsh/terraform-azurerm-aks?ref=plural"
  resource_group_name              = data.azurerm_resource_group.group.name
  kubernetes_version               = "1.20.5"
  orchestrator_version             = "1.20.5"
  prefix                           = var.name
  cluster_name                     = var.name
  network_plugin                   = "azure"
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  os_disk_size_gb                  = var.os_disk_size
  sku_tier                         = "Paid"
  private_cluster_enabled          = var.private_cluster
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = true
  agents_min_count                 = var.min_nodes
  agents_max_count                 = var.max_nodes
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = local.node_pool_name
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : local.node_pool_name
  }

  agents_tags = {
    "Agent" : "${local.node_pool_name}agent"
  }

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

  depends_on = [module.network]
}

data "azurerm_resource_group" "node_group" {
  name = module.aks.node_resource_group
}

resource "azurerm_role_assignment" "aks-managed-identity" {
  scope                = data.azurerm_resource_group.group.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_identity[0].object_id

  depends_on = [module.aks]
}

resource "azurerm_role_assignment" "aks-vm-contributor" {
  scope                = data.azurerm_resource_group.group.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = module.aks.kubelet_identity[0].object_id

  depends_on = [module.aks]
}

resource "azurerm_role_assignment" "aks-node-managed-identity" {
  scope                = data.azurerm_resource_group.node_group.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_identity[0].object_id

  depends_on = [module.aks]
}

resource "azurerm_role_assignment" "aks-node-vm-contributor" {
  scope                = data.azurerm_resource_group.node_group.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = module.aks.kubelet_identity[0].object_id

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "bootstrap" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "bootstrap"
    }
  }

  depends_on = [module.aks.host]
}
