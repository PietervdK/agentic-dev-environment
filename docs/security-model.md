# Security model

## Threat model

This repository automates changes to a developer's machine and interacts with package repositories and account tools. Main assets are SSH keys, GitHub/Codex sessions, global configuration, and source code. Risks include installing a substituted package, overwriting personal configuration, leaking a credential to version control, or granting an agent broader machine access than intended.

## Boundaries and controls

- Never put passwords, private keys, OAuth tokens, Codex credentials, or API keys in this repository.
- SSH keys remain under `~/.ssh`, with private key mode 600 and directory mode 700. Use a dedicated key and review account-wide GitHub access before uploading its public half.
- GitHub CLI and Codex authentication are interactive and owned by those tools.
- Prefer running Codex in a VM or disposable development environment when working with untrusted repositories.
- Review Codex's permission and network settings for the task. Limit filesystem access to the project where practical.
- `AGENTS.md`, skills, and prompts guide agent behavior. They are instructions, not an OS security sandbox; real access controls come from operating-system permissions and the agent's sandbox.
- Package installation uses distribution repositories. Codex uses the official OpenAI HTTPS installer only after explicit choice; it is downloaded to a temporary file and executed locally. Nix is optional and provides tools, not identity or secret management.

The bootstrap scripts are not a substitute for reviewing commands before granting elevated privileges.
