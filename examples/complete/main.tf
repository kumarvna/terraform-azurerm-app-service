module "web-app" {
  //  source  = "kumarvna/web-app/azurerm"
  //version = "1.0.0"
  source = "../../"

  # By default, this module will not create a resource group. Location will be same as existing RG.
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # set the argument to `create_resource_group = true` to create new resrouce group.
  resource_group_name = "rg-shared-westeurope-01"

  # App service plan setttings and supported arguments. Default name used by module
  # To specify custom name use `app_service_plan_name` with a valid name.  
  # for Service Plans, see https://azure.microsoft.com/en-us/pricing/details/app-service/windows/  
  # when using an App Service Plan in the `Free` or `Shared` Tiers `use_32_bit_worker_process` must be set to `true`.
  service_plan = ({
    kind = "Windows"
    size = "P1v2"
    tier = "PremiumV2"
  })

  # App Service settings and supported arguments
  # By default site_config, backup, connection_string, auth_settings, Storage for mounts are not created
  # Specify the these optional setting block here. more details check `README.md`
  app_service_name       = "mypocproject"
  enable_client_affinity = true

  # A `site_config` block to setup the application environment. 
  # List available built-in stacks (windows_fx_version) which can be used for web apps `az webapp list-runtimes`
  # List runtime stacks for Linux (linux_fx_version) based web apps `az webapp list-runtimes --linux`
  site_config = {
    always_on                 = true
    dotnet_framework_version  = "v4.0"
    ftps_state                = "FtpsOnly"
    managed_pipeline_mode     = "Integrated"
    use_32_bit_worker_process = true
    windows_fx_version        = "aspnet|V3.5"
  }
  # (Optional) A key-value pair of Application Settings
  app_settings = {
    DiagnosticServices_EXTENSION_VERSION = "~3"
  }

  # 
  enable_backup = true
  backup_settings = {
    enabled                  = true
    name                     = "DefaultBackup"
    frequency_interval       = 1
    frequency_unit           = "Day"
    retention_period_in_days = 90
  }

  storage_account_name = "stdiagfortesting"
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
