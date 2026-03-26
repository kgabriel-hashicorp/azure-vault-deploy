terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.23.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias                   = "image_factory"
  subscription_id          = "338f0fa5-b5ae-4847-9821-1808613db6c5" # hashicorp02-image-factory-prod
  features {}
}


provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory" # staging - for testing
  server_url = "https://acme-v02.api.letsencrypt.org/directory" # prod - for your real certs
}
