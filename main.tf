locals {
  vm_name = format("%s-%%02d", var.agent_name_prefix)
}

resource "hcloud_ssh_key" "this" {
  name       = "${var.agent_name_prefix}-ssh"
  public_key = var.ssh_public_key
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

  ssh_keys     = [hcloud_ssh_key.this.id]
  firewall_ids = [hcloud_firewall.agent.id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    azure_org_url     = var.azure_org_url
    azure_agent_pool  = var.azure_agent_pool
    azure_pat         = var.azure_pat
    agents_per_vm     = var.agents_per_vm
    agent_name_prefix = var.agent_name_prefix
    azdo_agent_version = var.azdo_agent_version
    ssh_public_key    = var.ssh_public_key
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
