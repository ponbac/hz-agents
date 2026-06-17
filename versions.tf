terraform {
  required_version = ">= 1.11.1"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49.1"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.15.0"
    }
  }
}
