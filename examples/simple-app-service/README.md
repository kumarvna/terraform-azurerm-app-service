# Azure App Service (Web Apps) Terraform Module

Terraform module to create Azure App Service with optional site_config, backup, connection_string, auth_settings and Storage for mount points.

## Module Usage

```hcl
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "app-service" {
  source  = "kumarvna/app-service/azurerm"
  version = "1.1.0"

  # By default, this module will not create a resource group. Location will be same as existing RG.
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # set the argument to `create_resource_group = true` to create new resrouce group.
  resource_group_name = "rg-shared-westeurope-01"

  # App service plan setttings and supported arguments. Default name used by module
  # To specify custom name use `app_service_plan_name` with a valid name.  
  # for Service Plans, see https://azure.microsoft.com/en-us/pricing/details/app-service/windows/  
  # App Service Plan for `Free` or `Shared` Tiers `use_32_bit_worker_process` must be set to `true`.
  service_plan = {
    kind = "Windows"
    size = "P1v2"
    tier = "PremiumV2"
  }

  # App Service settings and supported arguments
  # Backup, connection_string, auth_settings, Storage for mounts are optional configuration
  app_service_name       = "myapp-poc-project"
  enable_client_affinity = true

  # A `site_config` block to setup the application environment. 
  # Available built-in stacks (windows_fx_version) for web apps `az webapp list-runtimes`
  # Runtime stacks for Linux (linux_fx_version) based web apps `az webapp list-runtimes --linux`
  site_config = {
    always_on                 = true
    dotnet_framework_version  = "v2.0"
    ftps_state                = "FtpsOnly"
    managed_pipeline_mode     = "Integrated"
    use_32_bit_worker_process = true
    windows_fx_version        = "DOTNETCORE|2.1"
  }

  # (Optional) A key-value pair of Application Settings
  app_settings = {
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Java           = "1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }

  # The Backup feature in Azure App Service easily create app backups manually or on a schedule.
  # You can configure the backups to be retained up to an indefinite amount of time.
  # Azure storage account and container in the same subscription as the app that you want to back up. 
  # This module creates a Storage Container to keep the all backup items. 
  # Backup items - App configuration , File content, Database connected to your app
  enable_backup        = true
  storage_account_name = "stdiagfortesting1"
  backup_settings = {
    enabled                  = true
    name                     = "DefaultBackup"
    frequency_interval       = 1
    frequency_unit           = "Day"
    retention_period_in_days = 90
  }

  # By default App Insight resource is created by this module. 
  # Specify valid resource Id to `application_insights_id` to use existing App Insight
  # Specifies the type of Application by setting up `application_insights_type` with valid string
  # Specifies the retention period in days using `retention_in_days`. Default 90.
  # By default the real client ip is masked in the logs, to enable set `disable_ip_masking` to `true` 
  app_insights_name = "otkpocshared"

  # Adding TAG's to your Azure resources 
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
```

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.
