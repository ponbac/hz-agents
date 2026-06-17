locals {
  vm_name = format("%s-%%02d", var.agent_name_prefix)
}

data "hcloud_ssh_key" "this" {
  name = var.ssh_key_name
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
    azure_org_url      = var.azure_org_url
    azure_agent_pool   = var.azure_agent_pool
    azure_pat          = var.azure_pat
    agents_per_vm      = var.agents_per_vm
    agent_name_prefix  = var.agent_name_prefix
    azdo_agent_version = var.azdo_agent_version
    dotnet_version     = var.dotnet_version
    node_version       = var.node_version
    pnpm_version       = var.pnpm_version
    playwright_version = var.playwright_version
    ssh_public_key     = data.hcloud_ssh_key.this.public_key
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
