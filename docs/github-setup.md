# GitHub setup

Install or sign in to GitHub CLI with `gh auth login`. Choose GitHub.com, SSH for Git operations, and browser/device authentication. The CLI stores its own authentication state outside this repository; the bootstrapper does not read or print its token.

The optional SSH setup creates `~/.ssh/github_ai_dev_ed25519` only when absent. `ssh-keygen` prompts directly for any passphrase. The public key may be uploaded with `gh ssh-key add`; the private key is never uploaded. Review account-level key access before uploading: a key added to a GitHub account can access repositories that account can access.

If `~/.ssh/config` already has a GitHub host stanza outside this bootstrapper's marked block, setup leaves it untouched. Resolve conflicts manually. SSH verification recognizes GitHub's successful authentication message even when SSH returns a nonzero exit status because GitHub provides no shell.
