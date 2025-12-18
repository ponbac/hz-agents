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
  default     = "cx22"
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

variable "ssh_public_key" {
  description = "SSH public key string to authorize on the VM"
  type        = string
}

variable "azdo_agent_version" {
  description = "Pinned Azure DevOps agent version"
  type        = string
  default     = "3.248.0"
}
