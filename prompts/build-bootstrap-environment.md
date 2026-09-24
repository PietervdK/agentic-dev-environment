# Build a Reproducible Agentic Development Environment

Turn this repository into a reproducible, interactive setup for an AI-assisted software-development workstation.

The goal is that a developer can clone this repository onto a new supported machine, run one setup command, answer a small number of interactive questions, authenticate where necessary, and end up with a working development environment containing:

* Git;
* GitHub CLI;
* GitHub SSH authentication;
* Codex CLI;
* Codex global AGENTS.md;
* Codex skills;
* Codex reference files;
* common development CLI tools;
* optional Nix-based reproducible tooling;
* verification of the completed installation.

Follow all applicable global and repository AGENTS.md instructions.

Use installed development skills where relevant.

Do not commit.

Do not push.

Do not modify authentication credentials belonging to the current machine while developing this feature unless explicitly necessary for testing.

---

# 1. Primary user experience

The intended Linux experience should eventually be:

```bash
git clone <repository-url>
cd agentic-dev-environment
./setup.sh
```

The installer should:

1. detect the environment;
2. explain what it is going to configure;
3. inspect what is already installed;
4. ask only necessary questions;
5. install/configure missing components;
6. authenticate interactively where required;
7. verify the resulting environment;
8. print a concise completion summary.

Running the setup script multiple times must be safe.

The setup should be **idempotent** wherever practical.

---

# 2. Supported platforms

Support these environments:

## Primary

* Ubuntu
* Debian-compatible Linux

## Secondary

* Fedora or another common Linux distribution where practical

## Windows

Support Windows primarily through **WSL2** rather than maintaining a completely separate native Windows development stack.

Provide a PowerShell entry point:

`setup.ps1`

Its purpose is to:

* detect whether WSL2 is available;
* explain that the actual development environment will run inside WSL;
* guide or invoke the Linux setup inside WSL;
* avoid duplicating Linux setup logic in PowerShell.

Do not attempt to fully implement two unrelated Linux and Windows environments.

Prefer:

Windows
→ WSL2
→ Linux setup
→ same toolchain

If automatic WSL installation would require potentially disruptive system changes or reboot, explain and request confirmation instead of silently doing it.

---

# 3. Repository structure

Create a clear structure approximately like:

```text
agentic-dev-environment/
├── setup.sh
├── setup.ps1
├── README.md
├── .gitignore
│
├── codex/
│   ├── AGENTS.md
│   ├── skills/
│   └── references/
│
├── scripts/
│   ├── lib/
│   │   ├── common.sh
│   │   ├── platform.sh
│   │   └── ui.sh
│   │
│   ├── install-tools.sh
│   ├── setup-git.sh
│   ├── setup-github.sh
│   ├── setup-codex.sh
│   ├── setup-nix.sh
│   └── verify.sh
│
├── nix/
│   ├── flake.nix
│   └── flake.lock
│
├── templates/
│   └── project/
│
├── prompts/
│
└── docs/
    ├── architecture.md
    ├── github-setup.md
    ├── security-model.md
    └── troubleshooting.md
```

Adapt the exact structure if a simpler design is clearly better.

Keep the top-level `setup.sh` easy to understand.

Avoid creating a large framework around a relatively small bootstrap process.

---

# 4. Existing Codex configuration

Inspect the existing repository and current Codex configuration that has already been copied into this project.

The repository should version only reproducible Codex configuration such as:

* `AGENTS.md`;
* installed development skills;
* shared references/checklists.

Never copy or version the entire `~/.codex` directory blindly.

Do not include:

* authentication state;
* session history;
* cached data;
* runtime state;
* ChatGPT/Codex credentials;
* tokens.

During setup, install or synchronize repository-owned Codex configuration into:

```text
~/.codex/
```

For example:

```text
repo/codex/AGENTS.md
→ ~/.codex/AGENTS.md

repo/codex/skills/
→ ~/.codex/skills/

repo/codex/references/
→ ~/.codex/references/
```

Do this safely.

If existing user files would be overwritten:

1. detect the difference;
2. create a timestamped backup;
3. clearly tell the user;
4. then update only after confirmation or according to an explicitly documented safe policy.

Do not silently destroy existing custom Codex configuration.

---

# 5. Git configuration

The setup should verify that Git is installed.

If missing, install it using an appropriate supported mechanism.

Ask for or discover appropriate Git commit identity.

Prefer deriving the GitHub username after GitHub authentication where practical.

Allow configuration of:

* `user.name`;
* `user.email`.

Offer use of a GitHub noreply email.

Do not invent an email address.

If the user chooses a noreply address, either:

* retrieve/derive it reliably from GitHub information; or
* ask the user to provide the exact address.

Do not overwrite an existing global Git identity without confirmation.

---

# 6. GitHub CLI

Install the official GitHub CLI (`gh`) if it is not available.

Detect existing installation before changing anything.

After installation, check:

```bash
gh auth status
```

If the user is not authenticated, guide them through:

```bash
gh auth login
```

Prefer:

* GitHub.com;
* SSH for Git operations;
* browser/device authentication for GitHub CLI.

Do not attempt to capture, store, print, or commit the resulting OAuth token.

---

# 7. GitHub SSH key setup

The installer should support creating a dedicated SSH key for this development environment.

Use Ed25519.

Use a recognizable default path such as:

```text
~/.ssh/github_ai_dev_ed25519
```

but avoid overwriting an existing key.

If a key already exists, offer choices such as:

* reuse;
* inspect;
* create another key;
* skip SSH setup.

When creating the key:

* use `ssh-keygen`;
* allow `ssh-keygen` itself to ask the user for a passphrase;
* never capture or store that passphrase;
* never log it;
* never include it in configuration files.

Use a useful comment containing the machine hostname where practical.

Example concept:

```text
AI Development - hostname
```

---

# 8. Upload SSH public key through GitHub CLI

After `gh auth login` succeeds, offer to upload the public key to the authenticated GitHub account.

Use GitHub CLI rather than requiring the user to navigate the GitHub website manually where possible.

Give the key a recognizable title such as:

```text
AI Development - <hostname>
```

Only the `.pub` key may be uploaded.

Never upload or display the private key.

---

# 9. SSH configuration

Configure GitHub SSH cleanly in:

```text
~/.ssh/config
```

Use a configuration equivalent to:

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ai_dev_ed25519
    IdentitiesOnly yes
```

Do not destroy unrelated SSH configuration.

If `~/.ssh/config` already exists:

* parse or inspect it;
* preserve unrelated hosts;
* avoid duplicate conflicting `Host github.com` entries;
* back it up before modifying it.

Set secure filesystem permissions for:

* `~/.ssh`;
* private key;
* public key;
* SSH config.

---

# 10. SSH verification

Verify the resulting GitHub SSH authentication.

Use:

```bash
ssh -T git@github.com
```

Treat GitHub's normal:

```text
successfully authenticated, but GitHub does not provide shell access
```

response as success.

Handle the non-shell exit behavior correctly.

If authentication fails, provide useful diagnostics without exposing secrets.

---

# 11. Codex CLI

Check whether `codex` is already installed.

If not, install Codex using the current official supported installation mechanism.

Do not unnecessarily reinstall a working Codex CLI.

After installation verify:

```bash
codex --version
```

Ensure the user's shell PATH is correctly configured.

If the current shell needs reloading, explain that clearly.

---

# 12. Codex authentication

Do not attempt to automate or capture ChatGPT/Codex credentials.

If Codex is not authenticated, instruct the user to run Codex and authenticate interactively using their ChatGPT account.

The installer may launch the login process interactively if appropriate, but must not:

* store passwords;
* store session tokens in the repository;
* inspect authentication secrets.

Clearly distinguish:

* installation/configuration;
* interactive account authentication.

---

# 13. Development CLI tools

Provide a sensible small development baseline.

Consider tools such as:

* Git;
* curl;
* jq;
* ripgrep;
* Python;
* uv;
* Node.js where useful;
* shellcheck for development of this repository.

Do not install an enormous toolchain merely because it might someday be useful.

Prefer the smallest useful common baseline.

Project-specific dependencies should remain project-specific.

---

# 14. Nix

Add optional Nix support for reproducible development tooling.

Do NOT require NixOS.

The intended architecture is:

```text
Ubuntu / Fedora / WSL2
        ↓
       Nix
        ↓
   nix develop
        ↓
reproducible developer CLI environment
```

Create:

```text
nix/flake.nix
nix/flake.lock
```

or use a root-level `flake.nix` if that provides a cleaner standard user experience.

Prefer the conventional Nix layout if possible.

Provide a development shell containing the common non-secret development tools.

Do not attempt to manage:

* SSH private keys;
* GitHub authentication;
* Codex/ChatGPT authentication;

through Nix.

Those remain user-specific secrets/state.

During interactive setup, ask whether the user wants Nix installed/configured.

If they decline, the environment should still be usable through system packages.

Document the tradeoff:

* system packages = simpler;
* Nix = more reproducible.

---

# 15. Idempotency

A major requirement is that setup can be rerun safely.

For every important component, use logic conceptually like:

```text
already installed/configured?
        ↓
      yes → verify / skip
      no  → install/configure
```

Examples:

* Git installed → skip installation.
* GitHub CLI installed → verify.
* GitHub already authenticated → do not relogin unnecessarily.
* SSH key already exists → ask whether to reuse.
* Codex installed → verify/update only when justified.
* AGENTS.md exists → compare/backup instead of blindly overwriting.
* Nix already installed → reuse it.

Do not create duplicate config blocks on every run.

---

# 16. Dry-run / transparency

Where practical, add a mode such as:

```bash
./setup.sh --check
```

or:

```bash
./setup.sh --dry-run
```

that reports what would be changed without modifying the machine.

At minimum provide a verification-only mode.

For example:

```bash
./setup.sh --verify
```

This should check:

* platform;
* Git;
* Git config;
* GitHub CLI;
* GitHub authentication;
* SSH key/config;
* GitHub SSH authentication;
* Codex CLI;
* Codex configuration;
* installed skills/references;
* Nix availability where applicable.

---

# 17. Security requirements

Treat the bootstrapper as security-sensitive software.

Never write secrets into the repository.

Never print secrets to logs.

Never store:

* SSH private keys;
* SSH passphrases;
* GitHub OAuth tokens;
* ChatGPT/Codex tokens;
* API keys;
* passwords.

Do not run remote scripts blindly without understanding/documenting what they do.

For any remote installer used:

* use official sources;
* document the source;
* fail safely.

Use secure file permissions.

Quote shell variables properly.

Protect against paths containing spaces where practical.

Avoid unsafe `eval`.

Avoid predictable insecure temporary files.

Use `mktemp` where temporary files are needed.

Use `set -euo pipefail` only if the script is designed correctly around it and expected command failures are handled safely.

Do not run the whole bootstrap script as root.

Use `sudo` only around commands that genuinely require elevated privileges.

---

# 18. Backups

Before modifying important existing user configuration, create timestamped backups where appropriate.

Examples:

```text
~/.ssh/config
~/.codex/AGENTS.md
```

Use a clear backup location.

Do not back up private credentials into this Git repository.

---

# 19. Interactive UX

Keep the installer friendly and explicit.

Prefer questions like:

```text
Detected Ubuntu 24.04.

Git                    installed
GitHub CLI             installed
GitHub authentication  not configured
GitHub SSH key         not found
Codex                  installed
Codex config           update available
Nix                    not installed

Continue setup? [Y/n]
```

Avoid asking for information that can be discovered reliably.

Use sensible defaults.

Allow non-destructive cancellation.

Make error messages actionable.

Do not use unnecessary colors/animations if they reduce portability.

---

# 20. Windows / WSL PowerShell wrapper

Create `setup.ps1`.

Its responsibilities should be limited.

It should:

1. detect Windows;
2. detect WSL availability;
3. explain the architecture;
4. help start/install WSL when required;
5. locate this repository from inside WSL or provide clear instructions;
6. invoke the Linux `setup.sh` inside WSL.

Avoid reproducing all Linux bootstrap logic in PowerShell.

If a reboot is required to enable WSL, clearly stop and tell the user what to do next.

---

# 21. New-project helper

If reasonable within scope, provide an initial helper such as:

```bash
scripts/new-project
```

or install a command such as:

```bash
new-project
```

It should eventually help create a new project under a configurable projects directory.

For the first implementation, keep it minimal.

Potential behavior:

```text
new-project my-app
    ↓
create directory
    ↓
git init -b main
    ↓
copy generic project template
    ↓
ready for Codex
```

Do not automatically create or push a GitHub repository unless explicitly requested by the user.

Structure it so GitHub repo creation through `gh` can be added later.

---

# 22. Project template

Create a minimal generic project template containing only broadly useful files/directories, for example:

```text
prompts/
docs/
.gitignore
README.md
```

Do not assume every project is Python, Node, Django, or another specific technology.

Language/framework-specific templates can be added later.

---

# 23. README

Create a high-quality README for this repository.

It should explain the purpose:

> A reproducible AI-assisted software-development environment using Codex, GitHub, and optional Nix.

Document:

## Quick start — Linux

Expected final UX should be close to:

```bash
git clone <repo-url>
cd agentic-dev-environment
./setup.sh
```

## Quick start — Windows

Explain WSL2 architecture and:

```powershell
.\setup.ps1
```

## What gets installed/configured

Explain:

* Git;
* GitHub CLI;
* SSH;
* Codex;
* global AGENTS.md;
* skills;
* references;
* Nix option.

## What is NOT stored

Explicitly state that the repository never stores:

* private SSH keys;
* passwords;
* OAuth tokens;
* ChatGPT credentials;
* API keys.

## Re-running setup

Explain idempotency.

## Verification

Document:

```bash
./setup.sh --verify
```

## Troubleshooting

Link to troubleshooting documentation.

---

# 24. Architecture documentation

Create:

`docs/architecture.md`

Explain the boundaries:

```text
Operating system
     ↓
bootstrap
     ↓
Nix/system tooling
     ↓
Codex CLI harness
     ↓
global AGENTS.md + skills + references
     ↓
individual project repositories
```

Explain why credentials are intentionally outside version control.

---

# 25. Security documentation

Create:

`docs/security-model.md`

Document:

* threat model;
* VM isolation recommendation;
* SSH-key separation;
* credentials not stored in Git;
* account-level GitHub SSH implications;
* Codex agent permissions;
* difference between instruction boundaries and actual OS/security boundaries.

Do not claim AGENTS.md is a security sandbox.

---

# 26. Testing

Add meaningful tests or automated validation for the bootstrap scripts where practical.

At minimum:

* use `bash -n` for shell syntax;
* use ShellCheck if available;
* validate PowerShell syntax where feasible;
* test platform-detection functions;
* test config-generation functions against temporary directories;
* avoid tests modifying the real developer home directory.

Design scripts to make critical functions testable without touching real credentials.

Use temporary fake HOME directories where useful.

---

# 27. Current-machine safety

While building this project, do not:

* replace the current machine's working SSH key;
* delete current SSH configuration;
* remove current GitHub authentication;
* overwrite current Codex config without preserving it;
* modify current user secrets merely to test the installer.

Prefer unit/test execution against temporary directories.

If an end-to-end test would affect real credentials or authentication, stop and report the manual verification procedure instead.

---

# 28. Development workflow

Before implementing:

1. inspect the current repository;
2. inspect global AGENTS.md;
3. inspect available skills;
4. inspect existing Codex config included in the repository;
5. determine the current platform;
6. propose a concise architecture and implementation plan.

Then implement incrementally.

Use appropriate installed skills.

Run validation after meaningful changes.

Use debugging workflow when tests fail.

Perform code-quality and security review before completion.

---

# 29. Final verification

Before declaring the task complete:

1. run shell syntax checks;
2. run ShellCheck where available;
3. run any bootstrap unit tests;
4. review PowerShell script;
5. verify no secrets/private keys/tokens were added;
6. inspect `.gitignore`;
7. inspect `git diff`;
8. inspect `git status`;
9. perform code-quality review;
10. perform security review;
11. verify documentation matches actual behavior.

Do not run destructive end-to-end setup against the current workstation just to prove it works.

Provide manual end-to-end test instructions if necessary.

---

# 30. Completion report

When finished, report:

## Architecture

Describe the implemented bootstrap architecture.

## Linux setup

Explain what `setup.sh` does.

## Windows/WSL setup

Explain what `setup.ps1` does.

## Git/GitHub

Explain Git identity, `gh`, and SSH setup.

## Codex

Explain installation, AGENTS.md, skills, and references.

## Nix

Explain what is reproducible through Nix and what remains machine/user-specific.

## Security

Explain how secrets and credentials are protected.

## Testing

List checks/tests run and results.

## Usage

Give the expected clean-machine workflow.

## Limitations

List anything intentionally deferred.

## Git

Report current working-tree status.

Do not commit.

Do not push.

Do not make further changes after the final report unless explicitly requested.

## Git ignore policy

Configure a clear two-level ignore strategy.

### Global Git ignore

Support an optional global Git ignore file for machine/editor-specific noise only.

For example:

`~/.gitignore_global`

Potential entries:

* `.DS_Store`
* `Thumbs.db`
* editor swap files
* temporary backup files

If configured, use:

`git config --global core.excludesfile ~/.gitignore_global`

Do not put project-specific paths such as `.venv/`, `node_modules/`, `.env`, build output, or framework-specific artifacts in the global ignore file.

Do not overwrite an existing global ignore configuration without confirmation.

### Project template `.gitignore`

The generic project template must include a repository-local `.gitignore`.

It should contain only broadly useful safe defaults.

Do not assume every project uses Python, Node.js, Django, or another specific stack.

The `new-project` helper should copy this `.gitignore` into new projects automatically.

Language/framework-specific project templates may extend it later.

The setup or project helper must never add secrets such as `.env` files to Git tracking.

When a project stack is selected later, extend the local `.gitignore` with appropriate stack-specific entries rather than placing them in the global ignore configuration.
