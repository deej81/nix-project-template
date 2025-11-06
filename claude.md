# Nix Project Template - AI Assistant Context

## Project Overview

This is a **Copier-based template generator** for scaffolding NixOS server infrastructure projects. It creates reproducible, declarative server environments with built-in secrets management and infrastructure-as-code capabilities.

## Project Type

- **Primary Purpose:** Template/scaffold generator for NixOS server projects
- **Generator:** Copier (Python-based template tool)
- **Target Output:** Complete NixOS server configuration with optional infrastructure

## Core Technologies

- **Nix/NixOS:** Declarative package management and system configuration
- **Copier:** Template project generation with Jinja2 templating
- **SOPS + Age:** Encrypted secrets management
- **Python 3:** Infrastructure automation tools
- **Just:** Task runner for common operations

## Project Structure

```
.
├── flake.nix                    # Current template's Nix flake
├── flake.nix.jinja             # Template for generated projects
├── shell.nix                    # Development environment
├── copier.yml                   # Template configuration and prompts
├── justfile.jinja              # Generated project task runner
└── infrastructure/             # Optional server configuration (if VPS included)
    ├── server/                 # NixOS system configuration
    │   ├── base-config.nix    # Core system setup (SSH, Podman, packages)
    │   ├── configuration.nix   # User's custom configuration (empty template)
    │   ├── secrets.nix         # SOPS secrets integration
    │   ├── users.nix           # User management
    │   └── hardware/           # Hardware-specific configs (VM, ThinkPad, ISO)
    └── tools/                  # Python utilities for setup
        ├── setup_private_key.py
        ├── set_user_password.py
        ├── add_new_host.py
        └── shared/             # Shared utility modules
```

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Template's own configuration; defines `#initialise` app |
| `flake.nix.jinja` | Template for generated project flakes |
| `copier.yml` | Defines template prompts (project name, VPS inclusion, etc.) |
| `base-config.nix` | Base NixOS configuration with SSH, Podman, essential packages |
| `configuration.nix` | Empty file where users add custom NixOS configuration |
| `secrets.nix` | SOPS-based secrets management |
| `justfile.jinja` | Task definitions (VM management, ISO building, Aider) |

## Usage Pattern

1. **Initialize a new project:**
   ```bash
   nix run github:deej81/nix-project-template#initialise
   ```

2. **User prompted for:**
   - Project name
   - Include VPS infrastructure? (yes/no)
   - GitHub username
   - Initial username

3. **Generated project includes:**
   - Complete NixOS configuration (if VPS selected)
   - Secrets management infrastructure
   - Task runner with common operations
   - Development environment with necessary tools

## Important Conventions

- **Templating:** Uses Jinja2 syntax in `.jinja` files
- **Conditional Infrastructure:** VPS infrastructure only included if user opts in via Copier prompts
- **Secrets:** Age encryption + SOPS for all secrets
- **Hardware Configs:** Multiple profiles (VM, ThinkPad, custom ISO)
- **Task Runner:** `just` command for common operations

## Development Tools Included

- **Aider:** AI coding assistant (with API key management)
- **Direnv:** Automatic environment activation
- **FZF:** Fuzzy finder for interactive prompts
- **NIL:** Nix language server
- **QEMU:** VM testing and development

## Common Tasks (in generated projects)

- `just aider` - Launch AI coding assistant
- `just create-vm-disk` - Create QEMU VM disk
- `just run-vm-install-mode` - Boot VM for installation
- `just build-iso` - Generate bootable NixOS ISO

## Infrastructure Features (when VPS included)

- **Declarative System Config:** Everything defined in Nix
- **Secrets Management:** SOPS + Age encryption
- **Container Support:** Podman with Docker compatibility
- **Multiple Deployment Targets:** VM, physical hardware, ISO installer
- **SSH Hardening:** Configured in base-config.nix
- **Disk Partitioning:** Disko for declarative disk setup

## Working with This Codebase

- **Template files** use `.jinja` extension and Jinja2 syntax (`{% if %}`, `{{ variable }}`)
- **Non-template files** (no `.jinja`) are the template's own infrastructure
- **Python tools** in `infrastructure/tools/` handle secrets and host setup
- **Base configuration** is intentionally minimal; users extend via `configuration.nix`
- **Flake inputs** are conditional based on template choices (e.g., sops-nix only if VPS included)

## Notes for AI Assistants

- When editing `.jinja` files, preserve Jinja2 template syntax
- The project has two "layers": the template itself and the generated output
- `copier.yml` controls what gets included in generated projects
- Infrastructure setup is optional; not all generated projects include server config
- Secrets workflow: Age key → SOPS encryption → NixOS integration
