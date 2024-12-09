resource "azurerm_monitor_metric_alert" "alert_rules" {
  for_each = var.alert_rules

  name                = each.value["name"]
  description         = each.value["description"]
  resource_group_name = var.resource_group
  scopes              = var.data_factory_id
  severity            = each.value["severity"]
  frequency           = each.value["check_every"]
  window_size         = each.value["loopback_period"]

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = each.value["metric_name"]
    aggregation      = each.value["aggregation"]
    operator         = each.value["operator"]
    threshold        = each.value["threshold"]

    dynamic "dimension" {
      for_each = each.value["dimensions"] != null ? each.value["dimensions"] : []
      content {
        name     = dimension.value["dimension_name"]
        operator = dimension.value["operator"]
        values   = dimension.value["values"]
      }
    }
  }

  action {
    action_group_id = var.action_group_ids[each.value["action_group_key"]]
  }
  tags = var.tags
}