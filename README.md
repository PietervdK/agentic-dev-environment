# Agentic Development Environment

A reproducible AI-assisted software-development environment using Codex, GitHub, and optional Nix.

## Quick start — Linux

```bash
git clone <repository-url>
cd agentic-dev-environment
./setup.sh
```

The setup detects Ubuntu, Debian, or Fedora; explains its actions; checks installed tools; then guides Git, GitHub CLI, SSH, and Codex setup. It may use `sudo` for system packages but never runs the whole bootstrap as root. Authentication stays interactive.

## Quick start — Windows

The supported Windows path uses WSL2. PowerShell delegates to the same Linux setup:

```powershell
.\setup.ps1
```

If WSL needs installation or a reboot, the wrapper stops and tells you what to do next.

## What gets installed or configured

- Git, curl, jq, ripgrep, and Python 3 through the distribution package manager when missing.
- GitHub CLI authentication guidance and an optional dedicated Ed25519 SSH key. Only the public key may be uploaded.
- Codex CLI using the official OpenAI installer when chosen.
- Repository-owned `AGENTS.md`, skills, and references under `~/.codex/`.
- Optional Nix developer shell (`nix develop ./nix`) for reproducible CLI tools.
- `scripts/new-project NAME` creates a generic project under `~/projects` by default. Set `PROJECTS_DIR` to choose another parent.

System packages are simpler. Nix provides a pinned package set for the developer shell; OS integration, user configuration, and credentials remain outside it.

## What is not stored

The repository never stores private SSH keys, passwords, OAuth tokens, ChatGPT credentials, or API keys. Codex configuration synchronization copies repository-owned guidance from `codex/`, excluding Codex-managed `.system` skills and runtime caches. Differing user files require confirmation and receive a timestamped backup first. Non-interactive synchronization preserves differing files.

## Re-running setup

Setup checks existing installations and configuration before acting. It skips installed tools, keeps existing Git identity, avoids replacing SSH keys, and does not duplicate its SSH block. You can inspect planned package/configuration actions with:

```bash
./setup.sh --check
```

## Verification

```bash
./setup.sh --verify
```

This checks the platform, Git identity, GitHub CLI/authentication, SSH config and authentication, Codex CLI/configuration, and optional Nix availability. Account checks may report missing when you have not authenticated yet.

## Development checks

```bash
bash scripts/tests/test_helpers.sh
bash -n setup.sh scripts/*.sh scripts/new-project scripts/lib/*.sh scripts/tests/*.sh
```

ShellCheck is included in the baseline where available. Run `shellcheck setup.sh scripts/*.sh scripts/new-project scripts/lib/*.sh scripts/tests/*.sh` for linting.

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md), [docs/github-setup.md](docs/github-setup.md), and [docs/security-model.md](docs/security-model.md).
