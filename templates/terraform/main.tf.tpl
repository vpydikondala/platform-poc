terraform {
  required_version = ">= 1.7.0"
  backend "azurerm" {
      resource_group_name  = "idp-tfstate-rg"
      storage_account_name = "idppoctfstate12345"
      container_name       = "tfstate"
      key                  = "platform-poc.tfstate"
    }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}


provider "azurerm" { 
features {} 
subscription_id = "b603af5d-ccdb-4fa9-aa9d-abe1b070d49f"
}

resource "azurerm_resource_group" "rg" {
  name     = "${PREFIX}-rg"
  location = "${LOCATION}"
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${PREFIX}acr", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_storage_account" "sa" {
  name                            = replace("${PREFIX}docs", "-", "")
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "techdocs" {
  name                 = var.container_name
  storage_account_id   = azurerm_storage_account.sa.id
  container_access_type = "private"
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = replace("${PREFIX}-kv", "-", "")
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
}

resource "azurerm_user_assigned_identity" "backstage" {
  name                = "${PREFIX}-backstage-mi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "backstage_blob" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.backstage.principal_id
}

resource "azurerm_role_assignment" "backstage_kv" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.backstage.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${PREFIX}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${PREFIX}-aks"

  identity { type = "SystemAssigned" }

  default_node_pool {
    name       = "system"
    node_count = ${AKS_NODE_COUNT}
    vm_size    = "${AKS_VM_SIZE}"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile { network_plugin = "azure" }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "random_string" "pg_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "${PREFIX}-pg-${random_string.pg_suffix.result}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "${POSTGRES_VERSION}"
  administrator_login    = "${POSTGRES_ADMIN_USER}"
  administrator_password = "${POSTGRES_ADMIN_PASSWORD}"

  sku_name   = "${POSTGRES_SKU}"
  storage_mb = ${POSTGRES_STORAGE_GB} * 1024

  public_network_access_enabled = true
  backup_retention_days = 7
}

resource "azurerm_postgresql_flexible_server_database" "backstage" {
  name      = "backstage"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  count     = "${POSTGRES_ALLOW_AZURE}" == "true" ? 1 : 0
  name      = "AllowAzureServices"
  server_id = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "rg_name" { value = azurerm_resource_group.rg.name }
output "aks_name" { value = azurerm_kubernetes_cluster.aks.name }
output "acr_name" { value = azurerm_container_registry.acr.name }
output "storage_account" { value = azurerm_storage_account.sa.name }
output "keyvault_name" { value = azurerm_key_vault.kv.name }
output "backstage_mi_client_id" { value = azurerm_user_assigned_identity.backstage.client_id }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.aks.oidc_issuer_url }
output "postgres_fqdn" { value = azurerm_postgresql_flexible_server.pg.fqdn }
output "postgres_db" { value = azurerm_postgresql_flexible_server_database.backstage.name }
output "postgres_admin_user" { value = azurerm_postgresql_flexible_server.pg.administrator_login }
