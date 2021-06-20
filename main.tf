#---------------------------------
# Local declarations
#---------------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)

  app_insights = try(data.azurerm_application_insights.main.0, try(azurerm_application_insights.main.0, {}))

  default_app_settings = var.application_insights_enabled ? {
    APPLICATION_INSIGHTS_IKEY             = try(local.app_insights.instrumentation_key, "")
    APPINSIGHTS_INSTRUMENTATIONKEY        = try(local.app_insights.instrumentation_key, "")
    APPLICATIONINSIGHTS_CONNECTION_STRING = try(local.app_insights.connection_string, "")
  } : {}

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

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

data "azurerm_client_config" "main" {}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

resource "azurerm_app_service_plan" "main" {
  name                = var.app_service_plan_name == "" ? format("plan-%s", lower(replace(var.app_service_name, "/[[:^alnum:]]/", ""))) : var.app_service_plan_name
  resource_group_name = local.resource_group_name
  location            = local.location
  kind                = var.service_plan.kind
  reserved            = var.service_plan.kind == "Linux" ? true : false
  is_xenon            = var.service_plan.kind == "xenon" ? true : false
  per_site_scaling    = var.service_plan.per_site_scaling
  tags                = merge({ "ResourceName" = format("%s", var.app_service_plan_name) }, var.tags, )
  #  app_service_environment_id = add the feature later

  sku {
    tier     = var.service_plan.tier
    size     = var.service_plan.size
    capacity = var.service_plan.capacity
  }
}

resource "azurerm_app_service" "main" {
  name                    = lower(format("app-%s", var.app_service_name))
  resource_group_name     = local.resource_group_name
  location                = local.location
  app_service_plan_id     = azurerm_app_service_plan.main.id
  client_affinity_enabled = var.enable_client_affinity
  https_only              = var.enable_https
  client_cert_enabled     = var.enable_client_certificate
  tags                    = merge({ "ResourceName" = lower(format("app-%s", var.app_service_name)) }, var.tags, )
  app_settings            = merge(local.default_app_settings, var.app_settings)

  dynamic "site_config" {
    for_each = var.site_config

    content {
      always_on                   = lookup(site_config.value, "always_on", false)
      app_command_line            = lookup(site_config.value, "app_command_line", null)
      default_documents           = lookup(site_config.value, "default_documents", null)
      dotnet_framework_version    = lookup(site_config.value, "dotnet_framework_version", null)
      ftps_state                  = lookup(site_config.value, "ftps_state", "FtpsOnly")
      health_check_path           = lookup(site_config.value, "health_check_path", null)
      number_of_workers           = var.service_plan.per_site_scaling == true ? lookup(site_config.value, "number_of_workers") : null
      http2_enabled               = lookup(site_config.value, "http2_enabled", false)
      ip_restriction              = concat(local.subnets, local.ip_address, local.service_tags)
      scm_use_main_ip_restriction = var.scm_ips_allowed != [] || var.scm_subnet_ids_allowed != null ? false : true
      scm_ip_restriction          = concat(local.scm_subnets, local.scm_ip_address, local.service_tags)
      java_container              = lookup(site_config.value, "java_container", null)
      java_container_version      = lookup(site_config.value, "java_container_version", null)
      java_version                = lookup(site_config.value, "java_version", null)
      local_mysql_enabled         = lookup(site_config.value, "local_mysql_enabled", null)
      linux_fx_version            = lookup(site_config.value, "linux_fx_version", null)
      windows_fx_version          = lookup(site_config.value, "windows_fx_version", null)
      managed_pipeline_mode       = lookup(site_config.value, "managed_pipeline_mode", null)
      min_tls_version             = lookup(site_config.value, "min_tls_version", null)
      php_version                 = lookup(site_config.value, "php_version", null)
      python_version              = lookup(site_config.value, "python_version", null)
      remote_debugging_enabled    = lookup(site_config.value, "remote_debugging_enabled", null)
      remote_debugging_version    = lookup(site_config.value, "remote_debugging_version", null)
      scm_type                    = lookup(site_config.value, "scm_type", null)
      use_32_bit_worker_process   = lookup(site_config.value, "use_32_bit_worker_process", null)
      websockets_enabled          = lookup(site_config.value, "websockets_enabled", null)


      dynamic "cors" {
        for_each = lookup(site_config.value, "cors", [])
        content {
          allowed_origins     = cors.value.allowed_origins
          support_credentials = lookup(cors.value, "support_credentials", null)
        }
      }
    }
  }

  auth_settings {
    enabled                        = var.enable_auth_settings
    default_provider               = var.default_auth_provider
    allowed_external_redirect_urls = []
    issuer                         = format("https://sts.windows.net/%s/", data.azurerm_client_config.main.tenant_id)
    unauthenticated_client_action  = var.unauthenticated_client_action
    token_store_enabled            = var.token_store_enabled

    dynamic "active_directory" {
      for_each = var.active_directory_auth_setttings
      content {
        client_id         = lookup(active_directory_auth_setttings.value, "client_id", null)
        client_secret     = lookup(active_directory_auth_setttings.value, "client_secret", null)
        allowed_audiences = concat(formatlist("https://%s", [format("%s.azurewebsites.net", var.app_service_name)]), [])
      }
    }
  }

  dynamic "backup" {
    for_each = var.enable_backup ? [{}] : []
    content {
      name                = coalesce(var.backup_settings.name, "DefaultBackup")
      enabled             = var.backup_settings.enabled
      storage_account_url = var.backup_settings.storage_account_url
      schedule {
        frequency_interval       = var.backup_settings.frequency_interval
        frequency_unit           = var.backup_settings.frequency_unit
        retention_period_in_days = var.backup_settings.retention_period_in_days
        start_time               = var.backup_settings.start_time
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = lookup(connection_string.value, "name", null)
      type  = lookup(connection_string.value, "type", null)
      value = lookup(connection_string.value, "value", null)
    }
  }

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  dynamic "storage_account" {
    for_each = var.file_system_storage_account
    content {
      name         = lookup(storage_account.value, "name")
      type         = lookup(storage_account.value, "type", "AzureFiles")
      account_name = lookup(storage_account.value, "account_name", null)
      share_name   = lookup(storage_account.value, "share_name", null)
      access_key   = lookup(storage_account.value, "access_key", null)
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }

}
