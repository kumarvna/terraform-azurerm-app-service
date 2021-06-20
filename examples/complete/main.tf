module "web-app" {
  source = "github.com/kumarvna/terraform-azurerm-web-app?ref=develop"
  //source = "../../"

  # app_service_plan_name = "mydemoapp"
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  service_plan = ({
    kind = "Linux"
    size = "P1V2"
    tier = "PremiumV2"
  })

  app_service_name       = "mypocproject"
  app_insights_name      = "otkpocshared"
  enable_client_affinity = true

  site_config = {
    always_on                 = true
    dotnet_framework_version  = "v4.0"
    ftps_state                = "FtpsOnly"
    managed_pipeline_mode     = "Integrated"
    use_32_bit_worker_process = true
    linux_fx_version          = "DOTNET|5.0"
  }

  # Adding TAG's to your Azure resources (Required)
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
