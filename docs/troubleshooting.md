# Troubleshooting

- **Unsupported distribution:** The bootstrap currently supports Ubuntu, Debian, and Fedora. Install Git, curl, jq, ripgrep, Python 3, and ShellCheck through your distribution, then use the remaining setup modules.
- **GitHub CLI missing:** Install it using the instructions at [cli.github.com](https://cli.github.com/), then run `gh auth login` and rerun setup.
- **SSH fails:** Confirm the public key is present on the intended GitHub account with `gh ssh-key list`, inspect the `Host github.com` block, and run `ssh -vT git@github.com`. Check verbose output before sharing it.
- **Codex command missing after installation:** Open a new shell so the installer's PATH changes take effect, then run `codex --version`.
- **Codex configuration remains different:** Non-interactive sync preserves custom files. In an interactive terminal rerun `scripts/setup-codex.sh` to compare and selectively replace with a backup.
- **WSL path errors:** Run PowerShell from the repository checkout and confirm an Ubuntu/Debian WSL distribution is installed.
- **Nix:** Follow the official installation instructions at [nixos.org/download](https://nixos.org/download/), then run `nix develop ./nix`. This project does not execute a remote installer script.
