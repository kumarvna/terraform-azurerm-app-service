output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan component"
  value       = module.app-service.app_service_plan_id
}

output "maximum_number_of_workers" {
  description = " The maximum number of workers supported with the App Service Plan's sku"
  value       = module.app-service.maximum_number_of_workers
}

output "app_service_id" {
  description = "The resource ID of the App Service component"
  value       = module.app-service.app_service_id
}

output "default_site_hostname" {
  description = "The Default Hostname associated with the App Service"
  value       = module.app-service.default_site_hostname
}

output "outbound_ip_addresses" {
  description = "A comma separated list of outbound IP addresses"
  value       = module.app-service.outbound_ip_addresses
}

output "outbound_ip_address_list" {
  description = "A list of outbound IP addresses"
  value       = module.app-service.outbound_ip_address_list
}

output "possible_outbound_ip_addresses" {
  description = "A comma separated list of outbound IP addresses - not all of which are necessarily in use. Superset of `outbound_ip_addresses`."
  value       = module.app-service.possible_outbound_ip_addresses
}

output "possible_outbound_ip_address_list" {
  description = "A list of outbound IP addresses - not all of which are necessarily in use. Superset of outbound_ip_address_list."
  value       = module.app-service.possible_outbound_ip_address_list
}

output "identity" {
  description = "An identity block, which contains the Managed Service Identity information for this App Service."
  value       = module.app-service.identity
}

output "application_insights_id" {
  description = "The ID of the Application Insights component"
  value       = module.app-service.application_insights_id
}

output "application_insights_app_id" {
  description = "The App ID associated with this Application Insights component"
  value       = module.app-service.application_insights_app_id
}

output "application_insights_instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component"
  value       = module.app-service.application_insights_instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The Connection String for this Application Insights component"
  value       = module.app-service.application_insights_connection_string
  sensitive   = true
}

output "sas_url_query_string" {
  value     = module.app-service.sas_url_query_string
  sensitive = true
}

output "app_service_virtual_network_swift_connection_id" {
  description = "The ID of the App Service Virtual Network integration"
  value       = module.app-service.app_service_virtual_network_swift_connection_id
}
