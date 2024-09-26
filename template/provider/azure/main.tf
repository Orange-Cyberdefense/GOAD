terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.116.0"
    }
  }

  required_version = ">= 0.10.0"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "resource_group" {
  name     = "{{lab_identifier}}"
  location = var.location
}