variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "azure_pat" {
  description = "Azure DevOps PAT used by Terraform to manage the Azure DevOps pool/queue and by cloud-init to register agents"
  type        = string
  sensitive   = true
}

variable "azure_org_url" {
  description = "Azure DevOps organization URL (e.g. https://dev.azure.com/yourorg)"
  type        = string
}

variable "azure_project_name" {
  description = "Azure DevOps project name where the agent queue is authorized"
  type        = string
  default     = "Lerums Djursjukhus"
}

variable "azure_agent_pool" {
  description = "Dedicated Azure DevOps agent pool name managed by this configuration"
  type        = string
  default     = "LD.Apport-Hetzner"
}

variable "image" {
  description = "Hetzner image name"
  type        = string
  default     = "ubuntu-26.04"
}

variable "location" {
  description = "Hetzner location (e.g. nbg1, fsn1, hel1)"
  type        = string
  default     = "nbg1"
}

variable "server_type" {
  description = "Hetzner server type (e.g. cx22, cx43, cax11)"
  type        = string
  default     = "cx43"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be at least 1."
  }
}

variable "agents_per_vm" {
  description = "How many Azure agents to run per VM"
  type        = number
  default     = 1

  validation {
    condition     = var.agents_per_vm >= 1
    error_message = "agents_per_vm must be at least 1."
  }
}

variable "swap_size" {
  description = "Swapfile size configured on each VM to absorb CI memory spikes"
  type        = string
  default     = "8G"
}

variable "swap_swappiness" {
  description = "Linux vm.swappiness value for CI agents"
  type        = number
  default     = 10

  validation {
    condition     = var.swap_swappiness >= 0 && var.swap_swappiness <= 100
    error_message = "swap_swappiness must be between 0 and 100."
  }
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
  description = "Azure DevOps agent bootstrap version; the managed pool has auto_update enabled"
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
  description = "Playwright version used to preinstall Chromium system dependencies and browser binaries"
  type        = string
  default     = "1.61.0"
}

variable "sql_server_image" {
  description = "SQL Server container image pre-pulled for LD.Apport backend tests"
  type        = string
  default     = "mcr.microsoft.com/mssql/server:2025-CU2-ubuntu-22.04"
}
