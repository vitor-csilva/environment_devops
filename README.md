# Environment DevOps

A Bash script that sets up a Linux (Ubuntu) environment with everyday DevOps tools — in a single command.

```bash
git clone https://github.com/vitor-csilva/environment_devops.git
cd environment_devops
./devops_tools.sh
```

> **Requirement:** Ubuntu (or a derivative) with `sudo`. Reboot after installation.

---

## What gets installed

| Category | Tools |
|----------|-------|
| **Shell** | Zsh + Oh My Zsh (plugins: git, autosuggestions, kubectl, syntax-highlighting) |
| **Containers** | Docker |
| **Kubernetes** | kubectl, Krew (`neat`, `get-all`), Kind, Helm 4 |
| **IaC / Automation** | Terraform, Ansible |
| **Editors** | VS Code, Sublime Text |
| **CLI utils** | yq, jq |
| **Desktop** | Tilix, Flameshot, AnyDesk, Ferdium (Teams and other chat apps) |

---

## About Zsh & Oh My Zsh

### Zsh

Zsh is a UNIX command interpreter that works both as an interactive login shell and as a scripting language. Its flexibility and rich feature set make it a popular choice among developers.

### Oh My Zsh

[Oh My Zsh](https://ohmyz.sh/) is an open-source, community-driven framework for managing Zsh configuration. It improves the command-line experience with hundreds of plugins and themes.

This project installs Oh My Zsh with the following plugins:

| Plugin | Purpose |
|--------|---------|
| **git** | Extra Git helpers and aliases |
| **zsh-autosuggestions** | Suggests commands based on history |
| **kubectl** | Kubernetes command-line helpers |
| **zsh-syntax-highlighting** | Highlights commands as you type |

The default theme is set to `xiong-chiamiov-plus`.

---

## Usage

### Full install

```bash
./devops_tools.sh
```

### Skip specific tools

```bash
./devops_tools.sh --no-anydesk --no-ferdium
```

### Show all options

```bash
./devops_tools.sh --help
```

| Flag | Effect |
|------|--------|
| `--no-zsh` | Skip Zsh / Oh My Zsh |
| `--no-docker` | Skip Docker |
| `--no-kubectl` | Skip kubectl |
| `--no-krew` | Skip Krew and plugins |
| `--no-kind` | Skip Kind |
| `--no-helm` | Skip Helm 4 |
| `--no-ferdium` | Skip Ferdium |
| `--no-vscode` | Skip VS Code |
| `--no-tilix` | Skip Tilix |
| `--no-sublime` | Skip Sublime |
| `--no-yq` / `--no-jq` | Skip yq / jq |
| `--no-ansible` | Skip Ansible |
| `--no-terraform` | Skip Terraform |
| `--no-flameshot` | Skip Flameshot |
| `--no-anydesk` | Skip AnyDesk |

---

## Project structure

```text
environment_devops/
├── devops_tools.sh          # Main entrypoint (flags + orchestration)
├── libs/
│   └── functions_main.sh    # Install functions
└── anotacoes/               # Notes and improvements
```

---

## After installation

1. **Reboot** the system (default shell, Docker group, etc.).
2. **Docker:** if you have not rebooted yet, run `newgrp docker`.
3. **Kind:** `kind create cluster` (requires Docker running).
4. **Krew:** useful examples:
   ```bash
   kubectl neat get -- pod <name> -oyaml
   kubectl get-all
   ```
5. **Flameshot:** add a custom shortcut under *Settings → Keyboard → Custom Shortcuts*:
   - Command: `/bin/sh -c "flameshot gui > /dev/null &"`

---

## Author

Vitor Costa
