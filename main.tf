locals {
  vm_name = format("%s-%%02d", var.agent_name_prefix)

  configure_agent_environment_script = indent(6, chomp(templatefile("${path.module}/scripts/configure-agent-environment.sh.tftpl", {
    dotnet_version = var.dotnet_version
    node_version   = var.node_version
  })))

  install_agents_script = indent(6, chomp(templatefile("${path.module}/scripts/install-agents.sh.tftpl", {
    azure_org_url      = var.azure_org_url
    azure_agent_pool   = var.azure_agent_pool
    agents_per_vm      = var.agents_per_vm
    azdo_agent_version = var.azdo_agent_version
  })))

  install_powershell_script = indent(6, chomp(file("${path.module}/scripts/install-powershell.sh")))
}

data "hcloud_ssh_key" "this" {
  name = var.ssh_key_name
}

data "azuredevops_project" "this" {
  name = var.azure_project_name
}

resource "azuredevops_agent_pool" "this" {
  name           = var.azure_agent_pool
  auto_provision = false
  auto_update    = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuredevops_agent_queue" "this" {
  project_id    = data.azuredevops_project.this.id
  agent_pool_id = azuredevops_agent_pool.this.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuredevops_pipeline_authorization" "this" {
  project_id  = data.azuredevops_project.this.id
  resource_id = azuredevops_agent_queue.this.id
  type        = "queue"
}

resource "hcloud_firewall" "agent" {
  name = "${var.agent_name_prefix}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "agent" {
  count = var.vm_count

  name        = format(local.vm_name, count.index + 1)
  image       = var.image
  server_type = var.server_type
  location    = var.location

  ssh_keys     = [data.hcloud_ssh_key.this.id]
  firewall_ids = [hcloud_firewall.agent.id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    azure_pat                          = var.azure_pat
    configure_agent_environment_script = local.configure_agent_environment_script
    dotnet_version                     = var.dotnet_version
    install_agents_script              = local.install_agents_script
    install_powershell_script          = local.install_powershell_script
    node_version                       = var.node_version
    pnpm_version                       = var.pnpm_version
    playwright_version                 = var.playwright_version
    ssh_public_key                     = data.hcloud_ssh_key.this.public_key
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  depends_on = [azuredevops_pipeline_authorization.this]
}
