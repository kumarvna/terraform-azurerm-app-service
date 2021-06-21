data "azurerm_storage_account" "storeacc" {
  count               = var.enable_backup ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_storage_container" "storcont" {
  count                 = var.enable_backup ? 1 : 0
  name                  = var.storage_container_name == null ? "appservice-backup" : var.storage_container_name
  storage_account_name  = data.azurerm_storage_account.storeacc.0.name
  container_access_type = "private"
}

resource "time_rotating" "main" {
  count            = var.enable_backup ? 1 : 0
  rotation_rfc3339 = var.password_end_date
  rotation_years   = var.password_rotation_in_years

  triggers = {
    end_date = var.password_end_date
    years    = var.password_rotation_in_years
  }
}

/*
data "azurerm_storage_account_sas" "main" {
  count             = var.enable_backup ? 1 : 0
  connection_string = data.azurerm_storage_account.storeacc.0.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = time_rotating.main.0.rotation_rfc3339

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
}
*/

data "azurerm_storage_account_blob_container_sas" "main" {
  count             = var.enable_backup ? 1 : 0
  connection_string = data.azurerm_storage_account.storeacc.0.primary_connection_string
  container_name    = azurerm_storage_container.storcont.0.name
  https_only        = true

  start  = timestamp()
  expiry = time_rotating.main.0.rotation_rfc3339

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}
