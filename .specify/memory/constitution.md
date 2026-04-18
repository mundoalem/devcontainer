<!--
SYNC IMPACT REPORT
==================
Version change: [template / unversioned] → 1.0.0
Bump rationale: MINOR — initial constitution authoring; all placeholder tokens replaced with
                project-specific content derived from README, .env, Dockerfile structure, and
                CI/CD pipeline. No prior versioned constitution existed.

Modified principles:
  (none — this is the initial fill; all five principles created from scratch)

Added sections:
  - I. Reproducibility (new)
  - II. Multi-Platform Support (new)
  - III. Security by Default (new)
  - IV. Test Coverage (new)
  - V. Minimal, Justified Toolset (new)
  - Tool Versioning Policy (new)
  - Development Workflow (new)
  - Governance (new)

Removed sections:
  (none)

Templates reviewed:
  ✅ .specify/templates/plan-template.md   — "Constitution Check" gate present; aligns with
                                             all five principles; no update required.
  ✅ .specify/templates/spec-template.md  — No direct constitution references; acceptance
                                             criteria and FR format compatible; no update needed.
  ✅ .specify/templates/tasks-template.md — "Security hardening" in Polish phase aligns with
                                             Principle III; test-first task ordering aligns with
                                             Principle IV; no update required.
  ℹ️  .specify/templates/commands/        — Directory does not exist; no command templates found.

Deferred TODOs:
  (none — all fields resolved from project context)
-->

# devcontainer Constitution

## Core Principles

### I. Reproducibility

Every build MUST produce an identical environment given the same inputs. All tool versions MUST
be explicitly pinned in `src/Dockerfile`. Build arguments and environment variables are the
canonical source of truth: they MUST be defined in `.env` and passed as `--build-arg` to Docker.
No dynamic, unversioned, or "latest"-tagged package installs are permitted in the Dockerfile.

**Rationale**: Developers depend on this image for consistent, predictable tooling. Non-reproducible
builds cause hard-to-diagnose drift across developer machines, CI runners, and release artifacts.

### II. Multi-Platform Support

The image MUST support both `linux/arm64` and `linux/amd64` architectures. Any new tool added to
the image MUST have pre-built binaries available for both platforms, or MUST be compiled from source
in a platform-agnostic manner. Platform-specific installation branches MUST be explicitly marked in
`src/Dockerfile` and included in the BATS test suite for both architectures.

**Rationale**: The team operates on Apple Silicon (arm64) and x86-based (amd64) systems. A tool that
only works on one architecture fragments the developer environment and breaks the CI matrix build.

### III. Security by Default

All Dockerfiles MUST pass `hadolint` linting (rules configured in `.hadolint.yaml`) and `checkov`
security scanning before any release tag is pushed. Released images MUST be signed with `cosign`.
Linting rule suppressions MUST NOT be added inline inside Dockerfiles; every exception MUST be
declared in `.hadolint.yaml` with a brief justification comment. Security checks are enforced in CI
and are NOT optional gates.

**Rationale**: Developer containers carry elevated trust — passwordless sudo, mounted source trees,
access to credentials. The security posture of this image must be auditable and machine-enforced,
not left to individual author judgment.

### IV. Test Coverage

Every tool installed in the image MUST have at least one corresponding BATS test case in
`tests/unittest.bats` that verifies the tool is present and executable. Tests MUST run inside the
container via `task test` (not on the host). Removing a tool MUST be accompanied by removal of its
test. Adding a tool without a test case is a constitution violation and MUST NOT be merged.

**Rationale**: Dockerfile changes that silently break tool installation are undetectable without
in-container tests. Each tool must be independently verified in the actual runtime environment to
prevent silent regressions.

### V. Minimal, Justified Toolset

No tool may be added to the image without a documented, concrete use case tied to an active
development workflow. Tools MUST NOT be added speculatively. Each addition MUST update `README.md`
with the tool name, version, and category. Tool removals MUST also remove the corresponding
`README.md` entry and BATS test.

**Rationale**: Image size, build time, and maintenance burden grow with every tool. A curated,
justified toolset keeps the image lean, the build fast, and the long-term maintenance scope bounded.

## Tool Versioning Policy

All tools installed in `src/Dockerfile` MUST use explicit, pinned version strings (no `latest`,
no unversioned `apt install`). Version values are canonical in `src/Dockerfile`; `README.md` tool
tables MUST stay in sync. MAJOR version upgrades for any installed tool require human review and
explicit approval before merge. Automated patch/minor bumps in CI are permitted provided the full
pipeline (lint → scan → build → test) passes without modification.

## Development Workflow

The build system is [Task](https://taskfile.dev/) (`go-task`). All build, test, lint, scan, and
release operations MUST be invoked via `task` commands defined in `Taskfile.yml`. Environment
variables MUST be loaded from `.env` via `direnv allow` (or sourced manually for one-off runs).
Local overrides belong in `.env.local` (gitignored) and MUST NOT be committed. Direct `docker`
commands outside `Taskfile.yml` are strongly discouraged; they MUST NOT appear in CI workflow files.

The release pipeline is triggered exclusively by pushing a version tag (`v*`). Manual releases
bypassing the tag-based workflow are prohibited.

## Governance

This constitution supersedes all other development guidance for this project. Amendments require:

1. A pull request updating `.specify/memory/constitution.md` with a version bump.
2. A Sync Impact Report (embedded as an HTML comment at the top of the file) listing changed
   principles, added/removed sections, and template update status.
3. All dependent templates and `README.md` MUST be updated in the same pull request if affected.

Amendment version classification:
- **PATCH**: Wording, typo fixes, or clarifications with no behavioral or policy change.
- **MINOR**: New principle or section added; existing principle materially expanded.
- **MAJOR**: Principle removed, renamed, or redefined in a backward-incompatible way.

Every pull request touching `src/Dockerfile`, `tests/unittest.bats`, or `Taskfile.yml` MUST
include a Constitution Check confirming that no principles are violated. Complexity deviations
from any principle MUST be justified in the PR description before merge.

**Version**: 1.0.0 | **Ratified**: 2026-04-18 | **Last Amended**: 2026-04-18
