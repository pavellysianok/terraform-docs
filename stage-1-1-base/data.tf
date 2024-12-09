data "azurerm_client_config" "current" {
}

data "azurerm_key_vault" "keyvault" {
  name                = module.keyvault.name
  resource_group_name = module.resource_group.name
  depends_on          = [module.resource_group.name, module.keyvault.name]
}

data "azurerm_key_vault_secret" "opsgenie" {
  name         = "opsgenie-api-key"
  key_vault_id = module.keyvault.id
  depends_on   = [module.keyvault.name]
}

data "azurerm_monitor_action_group" "opsgenie" {
  resource_group_name = module.resource_group.name
  name                = "${module.resource_group.name}-opsg"
}