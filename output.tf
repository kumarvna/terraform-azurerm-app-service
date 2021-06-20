output "app_service_plan_id" {
  description = "The ID of the App Service Plan component"
  value       = azurerm_app_service_plan.main.id
}

output "maximum_number_of_workers" {
  description = " The maximum number of workers supported with the App Service Plan's sku"
  value       = azurerm_app_service_plan.main.maximum_number_of_workers
}

output "application_insights_id" {
  description = "The ID of the Application Insights component"
  value       = azurerm_application_insights.main.*.id
}

output "application_insights_app_id" {
  description = "The App ID associated with this Application Insights component"
  value       = azurerm_application_insights.main.*.app_id
}

output "application_insights_instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component"
  value       = azurerm_application_insights.main.*.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The Connection String for this Application Insights component"
  value       = azurerm_application_insights.main.*.connection_string
  sensitive   = true
}
