# Hetzner Azure DevOps Agents (Terraform + Cloud-init)

Disposable build agents on Hetzner Cloud using Terraform and cloud-init. Ubuntu 24.04 by default, SSH key-only login, optional multiple agents per VM, firewall restricted to SSH only.

The default image is tuned for the `LD.Apport` Azure Pipelines workload: Docker, PowerShell, Azure CLI, .NET SDK 10, Node.js 24, pnpm through corepack, and Chromium system dependencies for Playwright. .NET and Node are installed with `mise`, but the agent services use direct install paths instead of mise shims to avoid slow shim lookups during restores/builds.

## Files

- `versions.tf` — Terraform + provider constraints
- `providers.tf` — Hetzner provider
- `variables.tf` — configurable inputs
- `main.tf` — data lookup for SSH key, firewall, servers with user_data
- `cloud-init.yaml.tftpl` — cloud-init to install build tooling + Azure agent(s)
- `outputs.tf` — IPs and names
- `.gitignore` — ignores state, tfvars, etc.

## Required inputs

- `hcloud_token` (sensitive) — Hetzner API token
- `azure_pat` (sensitive) — ADO PAT with Agent Pools (Read & Manage)
- `azure_org_url` — e.g. `https://dev.azure.com/yourorg`
- `ssh_key_name` — name of the existing SSH key in Hetzner Cloud (used to attach to the server and authorize the `azureuser`)

## Common optional inputs (with defaults)

- `azure_agent_pool` = `Default`
- `image` = `ubuntu-24.04`
- `location` = `nbg1`
- `server_type` = `cpx42`
- `vm_count` = `1`
- `agents_per_vm` = `1` (set to `2+` to run multiple agents per VM)
- `agent_name_prefix` = `hz-agent`
- `azdo_agent_version` = `4.266.2` (pinned)
- `dotnet_version` = `10.0.300` (matches `LD.Apport/mise.toml`)
- `node_version` = `24.13.0`
- `pnpm_version` = `11.5.0` (matches `LD.Apport.Frontend/package.json`)
- `playwright_version` = `1.60.0` (used only to install Chromium OS dependencies; matches the current frontend lockfile)

## Usage

For local development, you can manage variables in a few ways.

### Option A: Local `.tfvars` file (Recommended)

Create a file named `secret.auto.tfvars` (automatically loaded and ignored by git):

```hcl
hcloud_token    = "your_hetzner_token"
azure_pat       = "your_azure_pat"
azure_org_url   = "https://dev.azure.com/yourorg"
ssh_key_name    = "your-existing-key-name"
```

### Option B: `.env` file

Create a `.env` file with `TF_VAR_` prefixes:

```bash
TF_VAR_hcloud_token="your_token"
TF_VAR_azure_pat="your_pat"
```

Load it before running:

```bash
export $(cat .env | xargs) && tofu plan
```

### Option C: Inline Environment Variables

```bash
# Initialize
tofu init

# Plan
TF_VAR_hcloud_token=... \
TF_VAR_azure_pat=... \
TF_VAR_azure_org_url="https://dev.azure.com/yourorg" \
TF_VAR_ssh_key_name="my-key" \
tofu plan
```

### Scaling

- More VMs: set `vm_count` (e.g. `TF_VAR_vm_count=3`).
- More agents per VM: set `agents_per_vm` (e.g. `TF_VAR_agents_per_vm=2`). Agent names become `<hostname>-1..N` (e.g., `hz-agent-01-1`).

### Upgrades / refresh

- Bump `image`, `azdo_agent_version`, or a tool version variable, then `terraform apply` (user_data changes recreate VMs for clean agents).
- To run an Azure Pipeline on these self-hosted agents, point the pipeline `pool` at `azure_agent_pool` instead of using `vmImage: ubuntu-latest` / `windows-latest`.

## Security notes

- PAT is injected via cloud-init and ends up in `terraform.tfstate`; store state securely (remote backend or protected local file).
- Hetzner firewall only opens SSH (22) to everywhere; OS UFW is also enabled for SSH only. Disable password auth (`ssh_pwauth: false`).
- Agents are configured with `AGENT_ALLOW_RUNASROOT=1`; for stricter isolation, refactor to run the service as a non-root user and avoid root tasks.

## Validation

- `tofu fmt`
- `tofu validate`

## Debugging

To view the cloud-init process after connecting to the VM via SSH, you can follow the output log:

```bash
sudo tail -f /var/log/cloud-init-output.log
```
