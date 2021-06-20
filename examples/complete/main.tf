module "web-app" {
  source = "github.com/kumarvna/terraform-azurerm-web-app?ref=develop"

  # app_service_plan_name = "mydemoapp"
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  service_plan = ({
    kind = "Linux"
    size = "S1"
    #capacity = 1
    tier = "Standard"
  })

  app_service_name = "mypocproject"

  # Adding TAG's to your Azure resources (Required)
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
