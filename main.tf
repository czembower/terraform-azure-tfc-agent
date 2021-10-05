provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfc_org_token
}

terraform {

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "myOrg"

    workspaces {
      name = "myWorkspace"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}
