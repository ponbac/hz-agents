# Hetzner Azure DevOps Agents (Terraform + Cloud-init)

Disposable build agents on Hetzner Cloud using Terraform and cloud-init. Ubuntu 26.04 by default, SSH key-only login, optional multiple agents per VM, firewall restricted to SSH only.

The default setup is tuned for the `LD.Apport` Azure Pipelines workload. Terraform creates the dedicated Azure DevOps agent pool/queue/authorization, then Hetzner VMs register self-hosted Linux agents into that pool. The image includes Docker, PowerShell, Azure CLI, .NET SDK 10, Node.js 24, pnpm through corepack, Chromium system dependencies and browser binaries for Playwright, and a pre-pulled SQL Server test image. .NET and Node are installed with `mise`, but the agent services use direct install paths instead of mise shims to avoid slow shim lookups during restores/builds.

## Files

- `versions.tf` — Terraform + provider constraints
- `providers.tf` — Hetzner + Azure DevOps providers
- `variables.tf` — configurable inputs
- `main.tf` — Azure DevOps pool/queue authorization, data lookup for SSH key, firewall, servers with user_data
- `cloud-init.yaml.tftpl` — cloud-init to install build tooling + Azure agent(s)
- `scripts/*.sh.tftpl` — rendered shell scripts embedded into cloud-init
- `outputs.tf` — IPs and names
- `.gitignore` — ignores state, tfvars, etc.

## Required inputs

- `hcloud_token` (sensitive) — Hetzner API token
- `azure_pat` (sensitive) — one Azure DevOps PAT used to manage the pool/queue and register agents. It needs enough access for Agent Pools read/manage, pipeline resource authorization, and reading the target project.
- `azure_org_url` — e.g. `https://dev.azure.com/yourorg`
- `ssh_key_name` — name of the existing SSH key in Hetzner Cloud (used to attach to the server and authorize the `azureuser`)

## Common optional inputs (with defaults)

- `azure_agent_pool` = `LD.Apport-Hetzner`
- `azure_project_name` = `Lerums Djursjukhus`
- `image` = `ubuntu-26.04`
- `location` = `nbg1`
- `server_type` = `cx43`
- `vm_count` = `1`
- `agents_per_vm` = `1` (set to `2+` to run multiple agents per VM)
- `agent_name_prefix` = `hz-agent`
- `azdo_agent_version` = `4.266.2` (bootstrap version; the managed pool has Azure DevOps agent auto-update enabled)
- `dotnet_version` = `10.0.300` (matches `LD.Apport/mise.toml`)
- `node_version` = `24.13.0`
- `pnpm_version` = `11.5.0` (matches `LD.Apport.Frontend/package.json`)
- `playwright_version` = `1.60.0` (used to install Chromium OS dependencies and browser binaries; matches the current frontend lockfile)
- `sql_server_image` = `mcr.microsoft.com/mssql/server:2025-CU2-ubuntu-22.04` (pre-pulled for backend integration tests)

## Usage

For local development, you can manage variables in a few ways.

### Option A: Local `.tfvars` file (Recommended)

Create a file named `secret.auto.tfvars` (automatically loaded and ignored by git):

```hcl
hcloud_token       = "your_hetzner_token"
azure_pat          = "your_azure_pat"
azure_org_url      = "https://dev.azure.com/yourorg"
azure_project_name = "Lerums Djursjukhus"
ssh_key_name       = "your-existing-key-name"
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

### Azure DevOps resources

This configuration owns the dedicated Azure DevOps pool named by `azure_agent_pool`, creates a project queue for `azure_project_name`, and authorizes that queue for pipelines. The pool and queue have `prevent_destroy` guardrails so accidental `tofu destroy` does not remove shared Azure DevOps CI resources without an intentional code change.

### Scaling

Initial capacity is one VM with one agent (`vm_count = 1`, `agents_per_vm = 1`). For future scale-out:

- More VMs: set `vm_count` (e.g. `TF_VAR_vm_count=3`).
- More agents per VM: set `agents_per_vm` (e.g. `TF_VAR_agents_per_vm=2`). Agent names become `<hostname>-1..N` (e.g., `hz-agent-01-1`). Only increase this after LD.Apport pipeline Docker usage is dynamic-port-safe and the Azure DevOps organization has enough self-hosted parallel-job capacity.

### Upgrades / refresh

- Bump `image`, `azdo_agent_version`, or a tool version variable, then `terraform apply` (user_data changes recreate VMs for clean agents).
- To run an Azure Pipeline on these self-hosted agents, point the pipeline `pool` at `azure_agent_pool` instead of using `vmImage: ubuntu-latest` / `windows-latest`.

## Security notes

- The single PAT is used by Terraform and injected via cloud-init for registration, so it can end up in `terraform.tfstate`; store state securely (remote backend or protected local file).
- Cloud-init deletes `/etc/azdo/pat` after agent registration. The registered agent still stores its Azure DevOps credentials in the agent directory as normal.
- Hetzner firewall only opens SSH (22) to everywhere; OS UFW is also enabled for SSH only. Disable password auth (`ssh_pwauth: false`).
- Agent services run as the dedicated non-sudo `azdoagent` user. That user is in the `docker` group so Azure Pipelines jobs can run Docker containers; treat Docker access as privileged host access.

## Validation

- `tofu init`
- `tofu fmt`
- `tofu validate`
- Render `cloud-init.yaml.tftpl` with representative variable values, parse it as YAML, and run `bash -n` on the rendered scripts before applying bootstrap changes.

## Debugging

To view the cloud-init process after connecting to the VM via SSH, you can follow the output log:

```bash
sudo tail -f /var/log/cloud-init-output.log
```
