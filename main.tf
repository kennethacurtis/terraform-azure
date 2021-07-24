# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "be868bd4-3bf7-4511-8065-c4a0917fa077"
  skip_provider_registration = true
}

terraform {
    backend "remote" {
        organization = "myshka"
        workspaces {
            name = "automation_platform"
        }
    }
}