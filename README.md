# fleet-ci — deterministic CI/CD for the fleet

- **gh-poll** — stdlib-only GitHub sweeper: per repo, squash-merges open PRs whose head-sha CI is green (optionally requiring a `REVIEW: PASS <sha>` comment), and files a `CI red on main` issue when the latest main run is red. Idempotent, exits 0, no model. `GH_TOKEN` env required.
- **gh-runner-install.sh** — registers the box as an org-level self-hosted Actions runner (`own-ci,fleet` labels) and installs it as a systemd service. Org runners are shared: GitHub dispatches each job to any idle runner — that is the load balancing.

## Wiring

- Poll every 15 min per box (stagger by box): `*/15 * * * * GH_TOKEN=... /usr/local/bin/gh-poll --repos /etc/fleet-ci/repos.txt --require-pass`
- Runners: one `gh-runner-install.sh` per box joins the org pool; every repo's `runs-on: [self-hosted, own-ci]` jobs fan out across all of them.
- Devin Cloud session VMs are ephemeral — do not install runners there.
