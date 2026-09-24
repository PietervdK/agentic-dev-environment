# Troubleshooting

- **Unsupported distribution:** The bootstrap currently supports Ubuntu, Debian, and Fedora. Install Git, curl, jq, ripgrep, Python 3, and ShellCheck through your distribution, then use the remaining setup modules.
- **GitHub CLI missing:** Install it using the instructions at [cli.github.com](https://cli.github.com/), then run `gh auth login` and rerun setup.
- **SSH fails:** Confirm the public key is present on the intended GitHub account with `gh ssh-key list`, inspect the `Host github.com` block, and run `ssh -vT git@github.com`. Check verbose output before sharing it.
- **Codex command missing after installation:** The official Linux installer places the command in `~/.local/bin` by default. Setup adds that directory to its own PATH immediately, and verification checks there too. New interactive terminals use the PATH update from the installer; if you chose a custom `CODEX_INSTALL_DIR`, ensure that directory is on your shell PATH as well.
- **Codex configuration remains different:** Non-interactive sync preserves custom files. In an interactive terminal rerun `scripts/setup-codex.sh` to compare and selectively replace with a backup.
- **WSL path errors:** Run PowerShell from the repository checkout and confirm an Ubuntu/Debian WSL distribution is installed.
- **Nix:** Installation is manual. Follow the official instructions at [nixos.org/download](https://nixos.org/download/), open a new terminal (or load Nix as the installer directs), and run `nix develop ./nix` from this repository. The setup script prints these steps when you choose its optional Nix guidance.
