#!/bin/bash
set -euo pipefail

. /etc/os-release
curl -fsSL -o /tmp/packages-microsoft-prod.deb "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb"
dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
apt-get update

if DEBIAN_FRONTEND=noninteractive apt-get install -y powershell; then
  exit 0
fi

asset_url=$(curl -fsSL https://api.github.com/repos/PowerShell/PowerShell/releases/latest |
  jq -r '[.assets[] | select(.name | test("^powershell_.*-1\\.deb_amd64\\.deb$"))][0].browser_download_url')

test -n "$asset_url"
test "$asset_url" != "null"

curl -fsSL "$asset_url" -o /tmp/powershell.deb
DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/powershell.deb
rm /tmp/powershell.deb
