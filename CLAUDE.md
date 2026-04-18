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

`task build` and `task test` iterate over `PROJECT_DOCKER_PLATFORMS` (comma-separated), building one image per arch tagged as `<name>:<version>-<arch>`. To target a single arch locally, override the variable:

```bash
PROJECT_DOCKER_PLATFORMS=linux/amd64 task build
PROJECT_DOCKER_PLATFORMS=linux/amd64 task test
```

To override variables without editing `.env`, create `.env.local` (gitignored) — `direnv` loads it after `.env`.

## Architecture

```
src/Dockerfile        # Main image — two-phase: root tools, then dev-user tools
src/Dockerfile.test   # Test harness: inherits FROM main image, runs BATS suite
tests/unittest.bats   # BATS test cases verifying tool installation & user config
Taskfile.yml          # All build/test/lint/release orchestration
policies/             # Custom Checkov policy directory (currently empty placeholder)
.env                  # Canonical project variables (version, platforms, user defaults)
.hadolint.yaml        # Hadolint ignore rules — add exceptions here, not inline
.github/workflows/pipeline.yml  # CI/CD: lint → scan → build+test (arm64 & amd64 in parallel) → release
```

### Dockerfile structure

`src/Dockerfile` has two clearly separated phases marked by comments:

1. **`SETUP: BASE`** — system packages and tools installed as root that must come before user creation (cosign, uv, hadolint, tenv, terraform-docs, tflint, alejandra, task, goenv). Locale configuration also happens here.
2. **`SETUP: CUSTOM (AS DEV USER)`** — switches to `${DEFAULT_USER}`, installs user-scoped tools (claude, specify-cli via uv, nvm, pyenv, checkov via pipx), and configures shell init (direnv, goenv, pyenv hooks in `.bashrc`).

New tools that need root go in phase 1. Tools that install into the user's home directory or use `pipx`/`uv tool install` go in phase 2.

### Tool installation pattern

Every tool in `src/Dockerfile` follows this structure:

```dockerfile
ENV VERSION_TOOLNAME="x.y.z"
ENV URL_TOOLNAME="https://..."   # optional

RUN curl -sOL "${URL_TOOLNAME}" \
    && sha256sum -c checksums.txt --ignore-missing \
    && <install step> \
    && rm -f <downloaded files>
```

For multi-platform tools, map `TARGETARCH` to the binary's CPU naming convention inside the `RUN` step — different upstream projects use different conventions (`x86_64` vs `amd64`, `aarch64` vs `arm64`). See alejandra and hadolint for examples.

### CI pipeline

```
lint (arm64) → scan (arm64) → ci-arm (arm64) + ci-amd (amd64) → cd (arm64, tag-only)
```

The CD job only runs on `v*` tag pushes. It requires `DOCKERHUB_USER` and `DOCKERHUB_ACCESS_TOKEN` GitHub secrets. `PROJECT_DOCKER_EXTRA_ARGS` can be set as a GitHub Actions variable to pass extra flags to `docker build`.

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

Tests use [BATS](https://bats-core.readthedocs.io/). `task test` builds `src/Dockerfile.test` (which inherits FROM the main image, so a prior `task build` is required) and runs the container — the BATS suite executes at container startup.

Tests cover: user/group creation, sudo configuration, and `which <tool>` presence checks for every installed tool. There is no way to run a single test in isolation without modifying `tests/unittest.bats` and rebuilding the test image.

### Adding a new tool

When adding any tool, all three of these must be updated in the same change:

1. `src/Dockerfile` — install the tool following the version-pinned pattern above
2. `tests/unittest.bats` — add a `@test "<tool> is installed"` with `run which <tool>`
3. `README.md` — add the tool to the appropriate table with its pinned version

## Dockerfile Linting & Security

Hadolint is configured in `.hadolint.yaml` to ignore: `DL3008` (pin apt versions), `DL3050` (label schema), `DL3059` (consecutive RUNs), `SC2155` (declare/assign separately). Add new Hadolint exceptions to `.hadolint.yaml` — never inline.

For Checkov, inline skips (`#checkov:skip=RULE:reason`) are acceptable only when the security trade-off is intentional and documented (e.g., the `CKV2_DOCKER_1` sudo skip at the top of `src/Dockerfile`). Custom Checkov policies can be placed in `policies/`.
