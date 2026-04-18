# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based development container image (`mundoalem/devcontainer`) built on Ubuntu 24.04, targeting VS Code Remote Dev Containers. It ships a curated set of development tools and supports multi-platform builds (linux/arm64, linux/amd64).

## Commands

The build system uses [Task](https://taskfile.dev/) (go-task). All tasks require environment variables from `.env` to be loaded first — `direnv` does this automatically if allowed.

```bash
# Load environment (one-time after clone)
direnv allow .

# Build image(s) for all configured platforms
task build

# Run BATS tests inside a container (requires prior build)
task test

# Lint Dockerfiles with hadolint
task lint

# Security scan with Checkov
task scan

# Remove built images
task clean

# Multi-platform push to Docker Hub (CI only — requires DOCKERHUB_* secrets)
task release
```

`task build` and `task test` iterate over `PROJECT_DOCKER_PLATFORMS` (comma-separated), building one image per arch tagged as `<name>:<version>-<arch>`.

To override variables without editing `.env`, create `.env.local` (gitignored) — `direnv` loads it after `.env`.

## Architecture

```
src/Dockerfile        # Main image — installed tools, user setup
src/Dockerfile.test   # Test harness: inherits from main image, runs BATS suite
tests/unittest.bats   # 19 BATS test cases verifying tool installation & user config
Taskfile.yml          # All build/test/lint/release orchestration
.env                  # Canonical project variables (version, platforms, user defaults)
.github/workflows/pipeline.yml  # CI/CD: lint → scan → build+test (arm64 & amd64 in parallel) → release
```

The release pipeline is triggered by pushing a version tag (`v*`). The `task release` command uses `docker buildx` to produce and push a single multi-platform manifest.

## Key Environment Variables

Defined in `.env` and passed as `--build-arg` to Docker:

| Variable | Default | Purpose |
|---|---|---|
| `PROJECT_VERSION` | `1.4.0` | Image tag and build label |
| `PROJECT_DOCKER_PLATFORMS` | `linux/arm64,linux/amd64` | Target architectures |
| `DEFAULT_USER` | `dev` | Non-root user created in image |
| `DEFAULT_USER_PRIMARY_GROUP` | `developers` | Primary group |
| `DEFAULT_USER_SECONDARY_GROUPS` | `sudo` | Secondary groups (passwordless sudo) |
| `DEFAULT_USER_SHELL` | `/bin/bash` | Login shell |
| `DEFAULT_LANG` | `C.UTF-8` | System locale |

## Testing

Tests use [BATS](https://bats-core.readthedocs.io/) (Bash Automated Testing System). `task test` builds `src/Dockerfile.test` (which inherits from the main image) and runs the container — the BATS suite executes at container startup.

Tests cover: user/group creation, sudo access, and presence of every installed tool. There is no way to run a single test in isolation without modifying `tests/unittest.bats` and rebuilding the test image.

## Dockerfile Linting Rules

Hadolint is configured in `.hadolint.yaml` to ignore: `DL3008` (pin apt versions), `DL3050` (label schema), `DL3059` (consecutive RUNs), `SC2155` (declare/assign separately). Do not add suppressions inline; add them to `.hadolint.yaml` instead.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
