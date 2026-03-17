# Codex Tools


## Shared Guidance

Key shared guidance lives in:
- `AGENTS.md` for the always-on baseline
- `docs/AGENT_ENTRYPOINT.md` for agent bootstrapping and tool selection
- `docs/HOWTO.md` for choosing personas, skills, and scenarios
- `docs/PROMPT_GENERATION.md` for context-efficient planner-to-executor prompt generation

This repository hosts behavioral **personas**, reusable **skills**, and task **scenarios** for Codex agents. Personas define working modes, skills are short selection cards for common methods, and scenarios hold the longer execution playbooks. The collection is published read-only through GitHub Pages for direct consumption by automation and other integrations.

## Persona Usage Guidelines

- Always select a persona before starting work on a task so the agent operates from a clear perspective.
- Switch personas explicitly when the task changes focus and document the active persona in status updates.
- Align tooling and communication with the currently selected persona to keep expectations consistent for collaborators.

### Catalog Audit Findings

- **Architect vs. Tech Lead** duplicated responsibilities around technical direction, reviews, and mentoring; the Tech Lead persona was merged into the refreshed Solution Architect profile.
- **DevOps vs. Security** overlapped on pipeline hardening and controls without a clear separation of duties; the refreshed DevOps Engineer now focuses on CI/CD efficiency, caching, and supply-chain guardrails, while the Reliability & Security Engineer retains broader operational resilience.
- **Senior Developer vs. Tech Lead** both focused on hands-on delivery with minimal differentiation; the Delivery Engineer persona now represents the shared implementation scope.
- **Missing operational continuity** — no single persona previously owned resiliency, compliance, and incident readiness; the new Reliability & Security Engineer fills that scenario.

### Core Persona Set (2025 Refresh)

| Persona | When to Use | Key Artifacts |
| --- | --- | --- |
| **Discovery Analyst** | Early discovery, backlog clarification, stakeholder alignment | Discovery brief, prioritized backlog, risk register |
| **Solution Architect** | Translating validated scope into technical plans | Mermaid diagrams, technical decision records, interface checklists |
| **Delivery Engineer** | Building and shipping production Rust changes | Implementation plan, PR checklist, post-merge notes |
| **Quality Engineer** | Designing coverage and enforcing release readiness | Test strategy, automation backlog, release quality checklist |
| **DevOps Engineer** | Optimizing CI/CD efficiency, caching, and supply-chain security | CI/CD performance baseline, cache strategy, pipeline security checklist |
| **Reliability & Security Engineer** | Hardening operations, compliance, and incident response | Operational readiness checklist, security review log, incident plan |

Each persona file in [`/personas/`](personas/) contains:

1. **Responsibilities checklist** — required activities before the persona considers the task complete.
2. **Switch triggers** — guidance on when to hand off to another persona as the work evolves.
3. **Required artifacts** — tangible outputs to produce and share during handover.

### Switching Playbook

1. Start in the persona whose responsibilities match the current blocker.
2. Review the "When to Switch Away" list to proactively identify the next handoff.
3. Produce the listed artifacts before switching personas to keep context intact.
4. Announce the persona change in status updates and share the prepared artifacts with the incoming persona.

## Scenario Library

Reusable task playbooks live in [`/scenarios/`](scenarios/) alongside personas and are published through GitHub Pages as Markdown prompts. Clients can discover them via the catalog at `https://qqrm.github.io/codex-tools/scenarios.json` and retrieve each scenario from `/scenarios/{id}.md`. When a user explicitly asks to run a named scenario—such as an architecture audit or dependency refresh—load the scenario prompt and combine it with the active persona to guide execution.

## Skill Library

Reusable selection cards live in [`/skills/`](skills/) and are published through GitHub Pages at `https://qqrm.github.io/codex-tools/skills.json`. Each skill gives a short answer to four questions:

1. what kind of method or review applies;
2. when that method should be used;
3. which persona should usually lead it;
4. which full scenario playbook to load next.

The intended flow is:

1. start from the base URL `/` or `index.json`;
2. load `AGENTS.md`;
3. load `docs/HOWTO.md`;
4. choose one persona from `personas.json`;
5. choose one or more skills from `skills.json`;
6. load the matching scenario only when the task needs the full execution playbook.

## Remote Setup

Configure the Git remote if it is missing:

```bash
git remote add origin https://github.com/qqrm/codex-tools.git
git fetch origin
```

### Codex Web bootstrap commands

Three published entry points cover the common Codex Web container workflows. Each snippet downloads the script from the GitHub Pages deployment and executes it directly:

> **Note:** The scripts refresh shared instructions from GitHub Pages before running. Override the download origin by exporting `PAGES_BASE_URL` when testing mirrors or forks.

> **Scope:** These scripts are for Codex Web or other ephemeral remote environments that need static bootstrap entrypoints. Local agents should not default to them; a local agent should instead use repository-local setup instructions or install missing tools directly when needed.

> **Bundle layout:** The published artifact exposes the three bootstrap entry points plus the build and validation helpers under `/scripts/`. Remote automation should execute only the three bootstrap entry points; the other scripts are published for inspection and reproducible local validation.

#### Non-cached container — full initialization
- Downloads the latest `AGENTS.md` from GitHub Pages to prime the workspace
- Performs the same tooling setup as the cached workflow on a brand new container
- Stores GitHub authentication, validates repository access, and installs the cleanup workflow

```bash
curl -fsSL "https://qqrm.github.io/codex-tools/scripts/FullInitialization.sh" | bash -s --
```

#### Cached container — full initialization
- Installs GitHub CLI, Rust, cargo-binstall, and helper tooling
- Persists GitHub authentication for later reuse inside the cached image
- Verifies repository access and installs the Codex cleanup workflow once

```bash
curl -fsSL "https://qqrm.github.io/codex-tools/scripts/BaseInitialization.sh" | bash -s --
```

#### Cached container — lightweight refresh before a task
- Updates the workspace copy of `AGENTS.md` from GitHub Pages

```bash
curl -fsSL "https://qqrm.github.io/codex-tools/scripts/PretaskInitialization.sh" | bash -s --
```

## Documentation

- **Specification:** See [`SPECIFICATION.md`](docs/SPECIFICATION.md) for the canonical directory layout, persona schema, and delivery expectations.
- **Personas:** Individual prompts live in [`/personas/`](personas/); each file targets a single role.
- **Base instructions:** Shared guidance for all personas resides in [`AGENTS.md`](AGENTS.md).
- **HTTP quick reference:** [`INSTRUCTIONS.md`](docs/INSTRUCTIONS.md) summarizes the published endpoints external clients call.
- **Selection guide:** [`HOWTO.md`](docs/HOWTO.md) explains how to choose personas, skills, and scenarios.
- **Tooling reference:** [`TOOLS.md`](docs/TOOLS.md) captures the shared CLI toolbelt used across repositories.

## Shared Files for External Consumers

External clients rely on a small set of shared files published alongside the personas:

- [`AGENTS.md`](AGENTS.md) — the baseline instructions served to external agents, embedded in and linked from the published `personas.json` catalog.
- [`docs/HOWTO.md`](docs/HOWTO.md) — the agent-facing selection guide for personas, skills, and scenarios.
- [`INSTRUCTIONS.md`](docs/INSTRUCTIONS.md) — a condensed description of the HTTP API exposed via GitHub Pages.
- [`skills/catalog.json`](skills/catalog.json) — the typed skills catalog published as `skills.json`.

Repository tooling keeps these artifacts in sync for local use:

- [`scripts/BaseInitialization.sh`](scripts/BaseInitialization.sh) — installs the required tooling and persists GitHub CLI authentication for cached Codex Web containers.
- [`scripts/FullInitialization.sh`](scripts/FullInitialization.sh) — performs the full bootstrap on a fresh, non-cached Codex Web container.
- [`scripts/PretaskInitialization.sh`](scripts/PretaskInitialization.sh) — refreshes the published assets before each Codex Web task.

These three scripts are the published bootstrap entry points that remote automation should execute. The Pages bundle also publishes the repository build and validation helpers for inspection and local reproduction.

### Published helper scripts

| Script | Purpose |
| --- | --- |
| [`scripts/FullInitialization.sh`](scripts/FullInitialization.sh) | Provisions a brand-new container with every required dependency and configuration. |
| [`scripts/BaseInitialization.sh`](scripts/BaseInitialization.sh) | Replays the tooling installation on cached containers so they stay aligned with the published baseline. |
| [`scripts/PretaskInitialization.sh`](scripts/PretaskInitialization.sh) | Refreshes `AGENTS.md` and validates workspace access before starting a task. |
| [`scripts/build-pages.sh`](scripts/build-pages.sh) | Rebuilds the persona catalog and prepares the GitHub Pages artifact. |
| [`scripts/validate-pages.sh`](scripts/validate-pages.sh) | Ensures the generated artifact exposes only the supported files and omits legacy helpers. |

> **Deprecated helper:** `scripts/agent-sync.sh` has been removed from the repository and the published artifact. Automation must run the repository's validation commands directly instead of relying on this script.

## Bootstrap Script Architecture

This section is the canonical reference for the bootstrap bundle described in Section 10 of `docs/SPECIFICATION.md`.

Codex repositories rely on a consistent bootstrap bundle to provision development containers. This repository publishes the entire bundle to GitHub Pages so automation can curl a single entry point and receive every dependency from the same source.

- **Entry points:** `scripts/BaseInitialization.sh`, `scripts/FullInitialization.sh`, and `scripts/PretaskInitialization.sh` are the only public URLs automation should call. Each script executes its workflow directly without sourcing additional helpers.
- **Mirroring strategy:** The scripts default to `https://qqrm.github.io/codex-tools` for every remote fetch, keeping the GitHub repository out of the execution path unless you override the base URL explicitly.

The published bundle initializes Codex Web-compatible containers by installing shared tooling, syncing repository assets, and verifying workflow prerequisites. Downstream repositories copy this pattern to keep remote container setup reproducible.

## Tooling

A Rust workspace under [`/crates/`](crates/) regenerates the catalog stored at [`personas/catalog.json`](personas/catalog.json) by parsing the persona front matter and bundling both the base instructions and persona metadata. The GitHub Pages deployment exposes this catalog as `personas.json` (the legacy `/catalog.json` alias is intentionally unavailable; clients must request `/personas.json`). The deployment pipeline rebuilds the index automatically whenever `main` changes, so running the generator locally is only necessary for debugging or previewing changes. Build the index with:

```bash
cargo run --release -p personas-core
```

Clients begin with the base URL `https://qqrm.github.io/codex-tools/`, which resolves to the published root manifest at `index.json`. That cold-start manifest reveals the typed catalogs, the baseline documents, and the machine-readable inventory for guides, scripts, workflows, skills, and scenarios. From there, clients fetch `AGENTS.md`, `docs/HOWTO.md`, `skills.json`, `personas.json`, and the specific Markdown assets they need. Requests to `/catalog.json` return `404 Not Found` by design; update clients rather than adding an alias.

`scripts/build-pages.sh` regenerates the catalog automatically before packaging the Pages artifact. When CI provides a pre-generated catalog, set `PERSONAS_CATALOG_SOURCE` to the artifact path so the script copies it into `personas/catalog.json` instead of invoking `cargo` again.

### GitHub Pages Publishing

The [GitHub Pages workflow](.github/workflows/pages.yml) publishes the persona catalog, shared instructions, and Markdown prompts whenever updates land on `main`. Refer to the workflow file for the complete automation steps.

### Published API

The latest version of the persona site is served from GitHub Pages at:

```text
https://qqrm.github.io/codex-tools/
```

- `GET /` — retrieve the cold-start discovery manifest served from `index.json`.
- `GET /index.json` — retrieve the root machine-readable manifest for the published bundle.
- `GET /entrypoint.json` — retrieve the same discovery manifest via a stable alias.
- `GET /skills.json` — retrieve the first-class skills catalog with task previews, recommended personas, and follow-up playbook links.
- `GET /personas.json` — retrieve the persona catalog, including the `base_uri` pointer to the shared instructions. The deployment does **not** publish `/catalog.json`.
- `GET /AGENTS.md` — download the shared baseline instructions referenced by `base_uri`.
- `GET /ENTRYPOINT.md` — fetch the human-readable agent bootstrap guidance referenced by `entrypoint.json`.
- `GET /docs/HOWTO.md` — fetch the short agent selection guide that explains how to choose personas, skills, and scenarios.
- `GET /docs/index.json` — enumerate the published docs catalog.
- `GET /docs/{name}.md` — fetch any published shared guidance document.
- `GET /personas/{id}.md` — retrieve the complete descriptor for the persona with the given `id`.
- `GET /skills/{id}.md` — retrieve the complete skill card for the requested method.
- `GET /scenarios.json` — retrieve the scenario catalog alongside persona metadata.
- `GET /scenarios/{id}.md` — fetch the scenario Markdown when requested by a catalog entry.
- `GET /scripts/index.json` — enumerate the published bootstrap and validation scripts.
- `GET /scripts/{name}.sh` — fetch any published bootstrap or validation script.
- `GET /workflows/index.json` — enumerate the published workflow catalog.
- `GET /workflows/{name}.yml` — inspect the workflows shipped with the Pages bundle.

Clients should begin with the base URL `/` or `index.json`, then follow the catalogs exposed there. The recommended cold-start order is `AGENTS.md`, `docs/HOWTO.md`, one persona, one or more skills, and only then the matching scenario playbooks. `entrypoint.json` stays published as an alias for integrations that already depend on that filename.

### Delivery diagrams

```mermaid
flowchart TD
  Client["Client agent"] -->|"fetch base URL"| Entrypoint["GET /<br/>served from index.json"]
  Entrypoint -->|"load baseline"| Agents["GET /AGENTS.md"]
  Entrypoint -->|"load selection guide"| HowTo["GET /docs/HOWTO.md"]
  Entrypoint -->|"discover skills"| Skills["GET /skills.json"]
  Entrypoint -->|"discover typed personas"| Catalog["GET /personas.json<br/>base_uri -> AGENTS.md"]
  Entrypoint -->|"discover shared docs"| Docs["GET /docs/index.json"]
  Client -->|"request persona"| Persona["GET /personas/{id}.md"]
  Client -->|"request skill"| Skill["GET /skills/{id}.md"]
  Client -->|"request scenario"| Scenario["GET /scenarios/{id}.md"]

  subgraph GitHubPages["GitHub Pages"]
    Entrypoint
    HowTo
    Skills
    Catalog
    Docs
    Agents
    Persona
    Skill
    Scenario
  end
```

```mermaid
flowchart TD
  Dev["Contributor edits personas, scenarios, docs, and scripts"]
  Generator["cargo run --release -p personas-core<br/>updates personas/catalog.json"]
  Bundle["scripts/build-pages.sh<br/>packages root manifest, skills.json, HOWTO, and catalogs"]
  Validate["scripts/validate-pages.sh<br/>ensures every published source file ships"]
  Pages["GitHub Pages artifact<br/>index.json + entrypoint.json + skills.json + catalogs"]
  Consumers["External automation"]

  Dev --> Generator --> Bundle --> Validate --> Pages --> Consumers
```

Continuous integration runs the full validation pipeline:

```bash
cargo fmt --all -- --check
cargo check --tests --benches
cargo clippy --all-targets --all-features -- -D warnings
cargo build --release
cargo test
cargo run --release -p personas-core
git diff --exit-code personas/catalog.json
./scripts/build-pages.sh
./scripts/validate-pages.sh
```

When working locally, reproduce this sequence for any change that touches source code. Markdown-only edits may instead run the lightweight loop of `./scripts/build-pages.sh` followed by `./scripts/validate-pages.sh`. GitHub Pages deployments rebuild the catalog from `main` and publish it to `https://qqrm.github.io/codex-tools/personas.json` alongside the persona Markdown files.

### Local validation shortcuts

- `make qa` — executes the formatter, `cargo check`, `cargo clippy` (static analysis), the release build, unit tests, and the documentation validation scripts in one pass.
- `make lint` — runs `cargo clippy --all-targets --all-features -- -D warnings` as the canonical static-analysis command.
- `make catalog` — rebuilds `personas/catalog.json` to preview the published catalog locally.

### Test coverage highlights

- `crates/core/src/lib.rs` — YAML parsing, catalog generation, and URI resolution logic.
- `crates/core/src/bin/generate_catalog.rs` — CLI validation of repository layout and catalog generation error handling.
- `crates/core/src/bin/generate_persona_audit.rs` — persona audit generation, `--check` drift detection, and argument parsing.

The validation script checks that the published artifact keeps the shared documentation and catalog files in sync. It fails if any tracked root Markdown file, published doc, persona, skill, scenario, shell script, or workflow expected from the repository source tree is missing or empty in the Pages bundle.

For detailed schemas, examples, and API usage, always defer to `SPECIFICATION.md`.
