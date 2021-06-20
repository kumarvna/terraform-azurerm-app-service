data "azurerm_application_insights" "main" {
  count               = var.application_insights_enabled && var.application_insights_id != null ? 1 : 0
  name                = split("/", var.application_insights_id)[8]
  resource_group_name = split("/", var.application_insights_id)[4]
}

resource "azurerm_application_insights" "main" {
  count               = var.application_insights_enabled && var.application_insights_id == null ? 1 : 0
  name                = lower(format("appi-%s", var.app_insights_name))
  location            = local.location
  resource_group_name = local.resource_group_name
  application_type    = var.application_insights_type
  retention_in_days   = var.retention_in_days
  disable_ip_masking  = var.disable_ip_masking
  tags                = merge({ "ResourceName" = "${var.app_insights_name}" }, var.tags, )
}
