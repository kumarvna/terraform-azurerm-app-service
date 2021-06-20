#---------------------------------
# Local declarations
#---------------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)

  # Default configuration for Site config block
  default_site_config = {
    always_on = "true"
  }

  # Enabling the App Insights on app service - default configuration for agent
  app_insights = try(data.azurerm_application_insights.main.0, try(azurerm_application_insights.main.0, {}))

  default_app_settings = var.application_insights_enabled ? {
    APPLICATION_INSIGHTS_IKEY                  = try(local.app_insights.instrumentation_key, "")
    APPINSIGHTS_INSTRUMENTATIONKEY             = try(local.app_insights.instrumentation_key, "")
    APPLICATIONINSIGHTS_CONNECTION_STRING      = try(local.app_insights.connection_string, "")
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
  } : {}

  # App service IP Address, Subnet_ids and Service_Tag restrictions
  ip_address = [for ip_address in var.ips_allowed : {
    name                      = "ip_restriction_cidr_${join("", [1, index(var.ips_allowed, ip_address)])}"
    ip_address                = ip_address
    virtual_network_subnet_id = null
    service_tag               = null
    subnet_id                 = null
    priority                  = join("", [1, index(var.ips_allowed, ip_address)])
    action                    = "Allow"
  }]

  subnets = [for subnet in var.subnet_ids_allowed : {
    name                      = "ip_restriction_subnet_${join("", [1, index(var.subnet_ids_allowed, subnet)])}"
    ip_address                = null
    virtual_network_subnet_id = subnet
    service_tag               = null
    subnet_id                 = subnet
    priority                  = join("", [1, index(var.subnet_ids_allowed, subnet)])
    action                    = "Allow"
  }]

  service_tags = [for service_tag in var.service_tags_allowed : {
    name                      = "service_tag_restriction_${join("", [1, index(var.service_tags_allowed, service_tag)])}"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = service_tag
    subnet_id                 = null
    priority                  = join("", [1, index(var.service_tags_allowed, service_tag)])
    action                    = "Allow"
  }]

  # App service SCM IP Address, SCM Subnet_ids andSCM  Service_Tag restrictions
  scm_ip_address = [for ip_address in var.scm_ips_allowed : {
    name                      = "scm_ip_restriction_cidr_${join("", [1, index(var.scm_ips_allowed, ip_address)])}"
    ip_address                = ip_address
    virtual_network_subnet_id = null
    service_tag               = null
    subnet_id                 = null
    priority                  = join("", [1, index(var.scm_ips_allowed, ip_address)])
    action                    = "Allow"
  }]

  scm_subnets = [for subnet in var.scm_subnet_ids_allowed : {
    name                      = "scm_ip_restriction_subnet_${join("", [1, index(var.scm_subnet_ids_allowed, subnet)])}"
    ip_address                = null
    virtual_network_subnet_id = subnet
    service_tag               = null
    subnet_id                 = subnet
    priority                  = join("", [1, index(var.scm_subnet_ids_allowed, subnet)])
    action                    = "Allow"
  }]

  scm_service_tags = [for service_tag in var.scm_service_tags_allowed : {
    name                      = "scm_service_tag_restriction_${join("", [1, index(var.scm_service_tags_allowed, service_tag)])}"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = service_tag
    subnet_id                 = null
    priority                  = join("", [1, index(var.scm_service_tags_allowed, service_tag)])
    action                    = "Allow"
  }]

}
