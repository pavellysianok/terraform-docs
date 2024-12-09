locals {
  env              = lower(var.environment)
  location         = lower(var.location)
  prefix           = "${local.env}-project"
  sa_prefix        = replace(local.env, "/[-_]/", "")


  # Environment specific settings

  nonprod_logs_storage_account_id = "/subscriptions/xxxxxxxxxxxxx/resourceGroups/rg1-name/providers/Microsoft.Storage/storageAccounts/storageaccount1"
  prod_logs_storage_account_id    = "/subscriptions/yyyyyyyyyyyyy/resourceGroups/rg2-name/providers/Microsoft.Storage/storageAccounts/storageaccount2"
  logs_storage_account_id         = startswith(local.env, "prod") ? local.prod_logs_storage_account_id : local.nonprod_logs_storage_account_id

  default_tags = {
    "Accolade Project"     = "Project name"
    "resource_owner"       = "RO name"
    "application"          = "APP name"
    "environment"          = title(split("-", local.env)[0])
    "cost_center"          = "TBD"
    "ticketing_tool"       = "TBD"
    "ticketing_queue_name" = "TBD"
  }

  tags = merge(local.default_tags, var.mandatory_tags)

  env_to_action_groups = {
    dev-01 = {
      opsg = {
        name        = "${local.prefix}-opsg"
        webhook_uri = replace("https://api.opsgenie.com/v1/json/azure?apiKey=secret", "secret", data.azurerm_key_vault_secret.opsgenie.value)
      }
    }
    qa-01 = {
      opsg = {
        name        = "${local.prefix}-opsg"
        webhook_uri = replace("https://api.opsgenie.com/v1/json/azure?apiKey=secret", "secret", data.azurerm_key_vault_secret.opsgenie.value)
      }
    }
    stg-01 = {
      opsg = {
        name        = "${local.prefix}-opsg"
        webhook_uri = replace("https://api.opsgenie.com/v1/json/azure?apiKey=secret", "secret", data.azurerm_key_vault_secret.opsgenie.value)
      }
    }
    prod-01 = {
      opsg = {
        name        = "${local.prefix}-opsg"
        webhook_uri = replace("https://api.opsgenie.com/v1/json/azure?apiKey=secret", "secret", data.azurerm_key_vault_secret.opsgenie.value)
      }
    }
  }

  action_group_key = format("%s_dbopsg", replace(local.env, "-01", ""))

  alerts_for_adf = {
    for alert_key, alert_value in local.metric_alert_rules : "${local.prefix}-${alert_key}" => {
      name             = "[ADF]-${local.prefix}-${alert_key}"
      action_group_key = local.action_group_key
      dimensions       = alert_value["dimensions"]
      metric_namespace = "Microsoft.DataFactory/factories"
      description      = alert_value["description"]
      metric_name      = alert_value["metric_name"]
      operator         = alert_value["operator"]
      threshold        = alert_value["threshold"]
    }
  }
}