# Azure App Service (Web Apps) Terraform Module

Azure App Service is a fully managed web hosting service for building web apps, mobile back ends and RESTful APIs. This terraform module helps you create Azure App Service with optional site_config, backup, connection_string, auth_settings and Storage for mount points.

## Module Usage

```hcl
module "web-app" {
  source  = "kumarvna/web-app/azurerm"
  version = "1.0.0"

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

## Recommended naming and tagging conventions

Well-defined naming and metadata tagging conventions help to quickly locate and manage resources. These conventions also help associate cloud usage costs with business teams via chargeback and show back accounting mechanisms.

> ### Resource naming

An effective naming convention assembles resource names by using important resource information as parts of a resource's name. For example, using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names), a public IP resource for a production SharePoint workload is named like this: `pip-sharepoint-prod-westus-001`.

> ### Metadata tags

When applying metadata tags to the cloud resources, you can include information about those assets that couldn't be included in the resource name. You can use that information to perform more sophisticated filtering and reporting on resources. This information can be used by IT or business teams to find resources or generate reports about resource usage and billing.

The following list provides the recommended common tags that capture important context and information about resources. Use this list as a starting point to establish your tagging conventions.

| Tag Name                  | Description                                                                                                                                                                                                    | Key             | Example Value                                 | Required? |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | --------------------------------------------- | --------- |
| Project Name              | Name of the Project for the infra is created. This is mandatory to create a resource names.                                                                                                                    | ProjectName     | {Project name}                                | Yes       |
| Application Name          | Name of the application, service, or workload the resource is associated with.                                                                                                                                 | ApplicationName | {app name}                                    | Yes       |
| Approver                  | Name Person responsible for approving costs related to this resource.                                                                                                                                          | Approver        | {email}                                       | Yes       |
| Business Unit             | Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this may represent a single corporate or shared top-level organizational element. | BusinessUnit    | FINANCE, MARKETING,{Product Name},CORP,SHARED | Yes       |
| Cost Center               | Accounting cost center associated with this resource.                                                                                                                                                          | CostCenter      | {number}                                      | Yes       |
| Disaster Recovery         | Business criticality of this application, workload, or service.                                                                                                                                                | DR              | Mission Critical, Critical, Essential         | Yes       |
| Environment               | Deployment environment of this application, workload, or service.                                                                                                                                              | Env             | Prod, Dev, QA, Stage, Test                    | Yes       |
| Owner Name                | Owner of the application, workload, or service.                                                                                                                                                                | Owner           | {email}                                       | Yes       |
| Requester Name            | User that requested the creation of this application.                                                                                                                                                          | Requestor       | {email}                                       | Yes       |
| Service Class             | Service Level Agreement level of this application, workload, or service.                                                                                                                                       | ServiceClass    | Dev, Bronze, Silver, Gold                     | Yes       |
| Start Date of the project | Date when this application, workload, or service was first deployed.                                                                                                                                           | StartDate       | {date}                                        | No        |
| End Date of the Project   | Date when this application, workload, or service is planned to be retired.                                                                                                                                     | EndDate         | {date}                                        | No        |

> This module allows you to manage the above metadata tags directly or as a variable using `variables.tf`. All Azure resources which support tagging can be tagged by specifying key-values in argument `tags`. Tag `ResourceName` is added automatically to all resources.

```hcl
module "web-app" {
  source  = "kumarvna/web-app/azurerm"
  version = "1.0.0"

  # ... omitted

  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
```

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.13   |
| azurerm   | >= 2.59.0 |

## Providers

| Name    | Version   |
| ------- | --------- |
| azurerm | >= 2.59.0 |

## Inputs

| Name                              | Description                                                                                                                                                                                                                                                      | Type              | Default                  |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------------------------ |
| `create_resource_group`           | Whether to create resource group and use it for all networking resources                                                                                                                                                                                         | string            | `"false"`                |
| `resource_group_name`             | The name of the resource group in which resources are created                                                                                                                                                                                                    | string            | `""`                     |
| `location`                        | The location of the resource group in which resources are created                                                                                                                                                                                                | string            | `""`                     |
| `app_service_plan_name`           | Specifies the name of the App Service Plan component                                                                                                                                                                                                             | string            | `""`                     |
| `service_plan`                    | Definition of the dedicated plan to use                                                                                                                                                                                                                          | object({})        | `{}`                     |
| `app_service_name`                | Specifies the name of the App Service                                                                                                                                                                                                                            | string            | `""`                     |
| `app_settings`                    | A key-value pair of App Settings                                                                                                                                                                                                                                 | map(string)       | `{}`                     |
| `site_config`                     | Site configuration for Application Service                                                                                                                                                                                                                       | any               | `{}`                     |
| `ips_allowed`                     | IPs restriction for App Service to allow specific IP addresses or ranges                                                                                                                                                                                         | list(string)      | `[]`                     |
| `subnet_ids_allowed`              | Allow Specific Subnets for App Service                                                                                                                                                                                                                           | list(string)      | `[]`                     |
| `service_tags_allowed`            | Restrict Service Tags for App Service                                                                                                                                                                                                                            | list(string)      | `[]`                     |
| `scm_ips_allowed`                 | SCM IP restrictions for App service                                                                                                                                                                                                                              | list(string)      | `[]`                     |
| `scm_subnet_ids_allowed`          | Restrict SCM Subnets for App Service                                                                                                                                                                                                                             | list(string)      | `[]`                     |
| `scm_service_tags_allowed`        | Restrict SCM Service Tags for App Service                                                                                                                                                                                                                        | list(string)      | `[]`                     |
| `enable_auth_settings`            | Specifies the Authenication enabled or not                                                                                                                                                                                                                       | string            | `false`                  |
| `default_auth_provider`           | The default provider to use when multiple providers have been set up. Possible values are `AzureActiveDirectory`, `Facebook`, `Google`, `MicrosoftAccount` and `Twitter`"                                                                                        | string            | `"AzureActiveDirectory"` |
| `unauthenticated_client_action`   | The action to take when an unauthenticated client attempts to access the app. Possible values are `AllowAnonymous` and `RedirectToLoginPage`                                                                                                                     | string            | `"RedirectToLoginPage"`  |
| `token_store_enabled`             | If enabled the module will durably store platform-specific security tokens that are obtained during login flows                                                                                                                                                  | string            | `false`                  |
| `active_directory_auth_setttings` | Acitve directory authentication provider settings for app service                                                                                                                                                                                                | any               | `{}`                     |
| `enable_client_affinity`          | Should the App Service send session affinity cookies, which route client requests in the same session to the same instance?                                                                                                                                      | string            | `false`                  |
| `enable_client_certificate`       | Does the App Service require client certificates for incoming requests                                                                                                                                                                                           | string            | `false`                  |
| `enable_https`                    | Can the App Service only be accessed via HTTPS?                                                                                                                                                                                                                  | string            | `false`                  |
| `enable_backup`                   | bool to to setup backup for app service                                                                                                                                                                                                                          | string            | `false`                  |
| `backup_settings`                 | Backup settings for App service                                                                                                                                                                                                                                  | object({})        | `{}`                     |
| `connection_strings`              | Connection strings for App Service                                                                                                                                                                                                                               | list(map(string)) | `[]`                     |
| `identity_ids`                    | Specifies a list of user managed identity ids to be assigned                                                                                                                                                                                                     | string            | `null`                   |
| `file_system_storage_account`     | Storage account mount points for App Service                                                                                                                                                                                                                     | list(map(string)) | `[]`                     |
| `custom_domains`                  | Custom domains with SSL binding and SSL certificates for the App Service. Getting the SSL certificate from an Azure Keyvault Certificate Secret or a file is possible                                                                                            | map(map(string))  | `null`                   |
| `application_insights_enabled`    | Specify the Application Insights use for this App Service                                                                                                                                                                                                        | string            | `true`                   |
| `application_insights_id`         | Resource ID of the existing Application Insights                                                                                                                                                                                                                 | string            | `null`                   |
| `app_insights_name`               | The Name of the application insights                                                                                                                                                                                                                             | string            | `""`                     |
| `application_insights_type`       | Specifies the type of Application Insights to create. Valid values are `ios` for iOS, `java` for Java web, `MobileCenter` for App Center, `Node.JS` for Node.js, `other` for General, `phone` for Windows Phone, `store` for Windows Store and `web` for ASP.NET | string            | `"web"`                  |
| `retention_in_days`               | Specifies the retention period in days. Possible values are `30`, `60`, `90`, `120`, `180`, `270`, `365`, `550` or `730`                                                                                                                                         | number            | `90`                     |
| `disable_ip_masking`              | By default the real client ip is masked as `0.0.0.0` in the logs. Use this argument to disable masking and log the real client ip                                                                                                                                | string            | `false`                  |
| `Tags`                            | A map of tags to add to all resources                                                                                                                                                                                                                            | map               | `{}`                     |

## Outputs

| Name                      | Description                              |
| ------------------------- | ---------------------------------------- |
| `windows_vm_extension_id` | Resource ID of Virtual Machine extension |

## Resource Graph

![Resource Graph](graph.png)

## Authors

Originally created by [Kumaraswamy Vithanala](mailto:kumarvna@gmail.com)

## Other resources

- [App Service(Web Apps)](https://docs.microsoft.com/en-us/azure/app-service/)
- [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)

```

```
