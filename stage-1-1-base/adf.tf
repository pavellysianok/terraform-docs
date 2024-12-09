locals {
  adf_name = "${local.prefix}-${local.location}"

  sftp_ls_name     = "example-ls"
  sftp_ls_host     = "sftp.example.com"
  sftp_ls_port     = 20021
  sftp_ls_username = "admin"

  kv_ls_name        = "${local.prefix}-${local.location}-kv-ls"
  kv_ls_secret_name = "sftp-secret"

  common_sa_names = [
    "${local.sa_prefix}mainh",
    "${local.sa_prefix}main2h",
    "${local.sa_prefix}datasource",
  ]

  adf_storage_accounts_per_env = {
    dev-01  = concat(local.common_sa_names)
    qa-01   = concat(local.common_sa_names)
    stg-01  = concat(local.common_sa_names)
    prod-01 = concat(local.common_sa_names)
  }
}

resource "azurerm_data_factory" "adf" {
  name                = local.adf_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = local.tags
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_service_key_vault" "keyvault" {
  name            = local.kv_ls_name
  data_factory_id = azurerm_data_factory.adf.id
  key_vault_id    = module.keyvault.id
}

resource "azurerm_data_factory_linked_custom_service" "sftp" {
  name            = local.sftp_ls_name
  data_factory_id = azurerm_data_factory.adf.id
  type            = "Sftp"
  type_properties_json = jsonencode({
    "host" : "${local.sftp_ls_host}",
    "port" : local.sftp_ls_port,
    "skipHostKeyValidation" : true,
    "authenticationType" : "SshPublicKey",
    "userName" : "${local.sftp_ls_username}",
    "privateKeyContent" : {
      "type" : "AzureKeyVaultSecret",
      "store" : {
        "referenceName" : "${local.kv_ls_name}",
        "type" : "LinkedServiceReference"
      },
      "secretName" : "${local.kv_ls_secret_name}"
    }
  })
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "storage_accounts_ls" {
  for_each = toset(local.adf_storage_accounts_per_env[local.env])

  name                 = "${each.key}-dl-ls"
  data_factory_id      = azurerm_data_factory.adf.id
  use_managed_identity = true
  url                  = "https://${each.key}.dfs.core.windows.net"
}

module "adf-alert-rules" {
  source = "../modules/azure-adf-monitor"

  alert_rules      = { for alert_key, alert_value in local.alerts_for_adf : alert_key => alert_value }
  data_factory_id  = [azurerm_data_factory.adf.id]
  resource_group   = module.resource_group.name
  action_groups    = local.env_to_action_groups[local.env]
  action_group_ids = { for k, v in local.env_to_action_groups[local.env] : k => data.azurerm_monitor_action_group.opsgenie.id }
  tags             = local.tags

  depends_on = [azurerm_data_factory.adf]
}