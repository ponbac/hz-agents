# Hetzner Azure DevOps Agents (Terraform + Cloud-init)

Disposable build agents on Hetzner Cloud using Terraform and cloud-init. Ubuntu 24.04 by default, SSH key-only login, optional multiple agents per VM, firewall restricted to SSH only.

## Files
- `versions.tf` — Terraform + provider constraints
- `providers.tf` — Hetzner provider
- `variables.tf` — configurable inputs
- `main.tf` — SSH key, firewall, servers with user_data
- `cloud-init.yaml.tftpl` — cloud-init to install Docker + Azure agent(s)
- `outputs.tf` — IPs and names
- `.gitignore` — ignores state, tfvars, etc.

## Required inputs
- `hcloud_token` (sensitive) — Hetzner API token
- `azure_pat` (sensitive) — ADO PAT with Agent Pools (Read & Manage)
- `azure_org_url` — e.g. `https://dev.azure.com/yourorg`
- `ssh_public_key` — paste your public key string

## Common optional inputs (with defaults)
- `azure_agent_pool` = `Default`
- `image` = `ubuntu-24.04`
- `location` = `nbg1`
- `server_type` = `cx22`
- `vm_count` = `1`
- `agents_per_vm` = `1` (set to `2+` to run multiple agents per VM)
- `agent_name_prefix` = `hz-agent`
- `azdo_agent_version` = `3.230.0` (pinned)

## Usage
```bash
# Initialize
terraform init

# Plan (env vars avoid shell history)
TF_VAR_hcloud_token=... \
TF_VAR_azure_pat=... \
TF_VAR_azure_org_url="https://dev.azure.com/yourorg" \
TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)" \
terraform plan

# Apply
TF_VAR_hcloud_token=... \
TF_VAR_azure_pat=... \
TF_VAR_azure_org_url="https://dev.azure.com/yourorg" \
TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)" \
terraform apply
```

### Scaling
- More VMs: set `vm_count` (e.g. `TF_VAR_vm_count=3`).
- More agents per VM: set `agents_per_vm` (e.g. `TF_VAR_agents_per_vm=2`). Agent names become `hz-agent-<hostname>-1..N`.

### Upgrades / refresh
- Bump `image` or `azdo_agent_version`, then `terraform apply` (user_data changes recreate VMs for clean agents).

## Security notes
- PAT is injected via cloud-init and ends up in `terraform.tfstate`; store state securely (remote backend or protected local file).
- Hetzner firewall only opens SSH (22) to everywhere; OS UFW is also enabled for SSH only. Disable password auth (`ssh_pwauth: false`).
- Agents are configured with `AGENT_ALLOW_RUNASROOT=1`; for stricter isolation, refactor to run the service as a non-root user and avoid root tasks.

## Validation
- `terraform fmt`
- `terraform validate`
