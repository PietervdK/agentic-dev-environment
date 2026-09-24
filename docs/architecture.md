# Architecture

```text
Operating system
     ↓
setup.sh and focused setup scripts
     ↓
system packages or optional Nix tooling
     ↓
Codex CLI harness
     ↓
global AGENTS.md, skills, and references
     ↓
individual project repositories
```

The Bash scripts own Linux setup. `setup.ps1` only locates the checkout in WSL and invokes that same entry point. Repository-owned Codex guidance is synchronized file by file; it does not copy the whole Codex runtime directory. Existing differing files are preserved by default and backed up before an interactive replacement.

Nix describes the non-secret CLI tool shell. GitHub and Codex account state, SSH private keys, and user-specific configuration remain in the operating system's home directory because storing those in a repository would expose them to every clone.
