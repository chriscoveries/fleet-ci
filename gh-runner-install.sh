#!/usr/bin/env bash
# gh-runner-install — register this box as an org-level GitHub Actions
# self-hosted runner and install it as a systemd service.
#
# Org runners are shared: GitHub dispatches each queued job to ANY idle
# runner with matching labels — that IS the load balancing. Labels used:
#   self-hosted, linux, x64, own-ci, fleet
#
# usage: GH_TOKEN=<org admin PAT> GH_ORG=<org> ./gh-runner-install.sh [name]
#   GH_ORG defaults to chriscoveries. name defaults to $(hostname).
set -euo pipefail
ORG="${GH_ORG:-chriscoveries}"
NAME="${1:-$(hostname)}"
DIR="$HOME/actions-runner"
VER="2.329.0"   # pin; bump deliberately
mkdir -p "$DIR" && cd "$DIR"

[ -f ./config.sh ] || {
  curl -fsSL "https://github.com/actions/runner/releases/download/v${VER}/actions-runner-linux-x64-${VER}.tar.gz" -o runner.tgz
  tar xzf runner.tgz
  TOKEN="$(curl -fsSL -X POST \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/orgs/$ORG/actions/runners/registration-token" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"
  ./config.sh --unattended --replace \
    --url "https://github.com/$ORG" \
    --token "$TOKEN" --name "$NAME" \
    --labels "own-ci,fleet" --work "_work"
}
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
echo "runner $NAME live (org=$ORG labels=self-hosted,linux,x64,own-ci,fleet)"
