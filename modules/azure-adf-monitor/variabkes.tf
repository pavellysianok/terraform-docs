variable "resource_group" {
  description = "The Name of Resource Group"
  type        = string
}

variable "tags" {
  description = "The tags to associate"
  type        = map(string)
}

variable "action_groups" {
  description = "List of Action Groups to create"
  type = map(object({
    name        = string
    webhook_uri = string
  }))
}

variable "alert_rules" {
  description = "List of Alert Rules to create"
  type = map(object({
    name             = string
    description      = optional(string, "Alert for ADF")
    metric_namespace = string
    metric_name      = optional(string, "IncomingMessages")
    aggregation      = optional(string, "Count")
    operator         = optional(string, "LessThanOrEqual")
    threshold        = optional(number, 0)
    severity         = optional(number, 3)
    action_group_key = string
    check_every      = optional(string, "PT5M")  # PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D. Defaults to PT5M
    loopback_period  = optional(string, "PT15M") #PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D. Defaults to PT5M
    dimensions = list(object({
      dimension_name = optional(string, "Name")
      operator       = optional(string, "Include") # Include, Exclude and StartsWith
      values         = optional(list(string), [""])
    }))
  }))
}

variable "data_factory_id" {
  description = "ID of the resource being monitored"
  type        = list(string)
}

variable "action_group_ids" {
  description = "Map of action group IDs, where the key is the action group name or key and the value is the action group ID."
  type        = map(string)
}