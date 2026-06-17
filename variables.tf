variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "azure_pat" {
  description = "Azure DevOps PAT with Agent Pools (Read & Manage)"
  type        = string
  sensitive   = true
}

variable "azure_org_url" {
  description = "Azure DevOps organization URL (e.g. https://dev.azure.com/yourorg)"
  type        = string
}

variable "azure_agent_pool" {
  description = "Azure DevOps agent pool name"
  type        = string
  default     = "Default"
}

variable "image" {
  description = "Hetzner image name"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner location (e.g. nbg1, fsn1, hel1)"
  type        = string
  default     = "nbg1"
}

variable "server_type" {
  description = "Hetzner server type (e.g. cx22, cax11)"
  type        = string
  default     = "cpx42"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "agents_per_vm" {
  description = "How many Azure agents to run per VM"
  type        = number
  default     = 1
}

variable "agent_name_prefix" {
  description = "Prefix for Azure agent names"
  type        = string
  default     = "hz-agent"
}

variable "ssh_key_name" {
  description = "Name of the existing SSH key in Hetzner Cloud"
  type        = string
}

variable "azdo_agent_version" {
  description = "Pinned Azure DevOps agent version"
  type        = string
  default     = "4.266.2"
}

variable "dotnet_version" {
  description = "Pinned .NET SDK version installed for Azure Pipelines jobs"
  type        = string
  default     = "10.0.300"
}

variable "node_version" {
  description = "Pinned Node.js version installed for Azure Pipelines jobs"
  type        = string
  default     = "24.13.0"
}

variable "pnpm_version" {
  description = "Pinned pnpm version prepared through corepack"
  type        = string
  default     = "11.5.0"
}

variable "playwright_version" {
  description = "Playwright version used to preinstall Chromium system dependencies"
  type        = string
  default     = "1.60.0"
}
