[![Release Status](https://github.com/mundoalem/devcontainer/actions/workflows/pipeline.yml/badge.svg)](https://github.com/mundoalem/devcontainer/actions/workflows/pipeline.yml)

# devcontainer

A Docker-based development environment for [Visual Studio Code](https://code.visualstudio.com/) via the [Remote Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension. It provides a consistent, pre-configured Linux environment with a curated set of development tools ready to use, supporting both `linux/amd64` and `linux/arm64` architectures.

## Base Image

| Component | Version       |
|-----------|---------------|
| Ubuntu    | 24.04 (noble) |

## Installed Tools

### Build & Utilities

| Tool | Version |
|------|---------|
| [Task](https://taskfile.dev/) | 3.49.1 |
| [direnv](https://direnv.net/) | 2.32.1 |
| [uv](https://docs.astral.sh/uv/) | 0.11.6 |
| [pipx](https://pipx.pypa.io/) | 1.4.3 |

### Language Version Managers

| Tool | Version |
|------|---------|
| [Pyenv](https://github.com/pyenv/pyenv) | 2.6.27 |
| [Goenv](https://github.com/go-nv/goenv) | 2.2.40 |
| [NVM](https://github.com/nvm-sh/nvm) | 0.40.4 |

### Infrastructure as Code

| Tool | Version |
|------|---------|
| [Tenv](https://github.com/tofuutils/tenv) | 4.10.1 |
| [Terraform-docs](https://terraform-docs.io/) | 0.22.0 |
| [TFLint](https://github.com/terraform-linters/tflint) | 0.61.0 |
| [Alejandra](https://github.com/kamadorueda/alejandra) (Nix formatter) | 4.0.0 |

### Security & Linting

| Tool | Version |
|------|---------|
| [Hadolint](https://github.com/hadolint/hadolint) | 2.14.0 |
| [Checkov](https://www.checkov.io/) | 3.2.519 |

### AI

| Tool | Version |
|------|---------|
| [Claude Code](https://claude.ai/code) | 2.1.104 |

## License

[GNU Affero General Public License Version 3](https://github.com/mundoalem/devcontainer/blob/main/LICENSE)
