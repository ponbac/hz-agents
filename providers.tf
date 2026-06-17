provider "hcloud" {
  token = var.hcloud_token
}

provider "azuredevops" {
  org_service_url       = var.azure_org_url
  personal_access_token = var.azure_pat
}
