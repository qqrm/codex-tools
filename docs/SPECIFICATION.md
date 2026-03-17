# Codex Tools Specification

## 1. Purpose

This specification defines how behavioral **personas**, reusable **skills**, reusable **scenarios**, shared tooling, and metadata are organized within the Codex Tools repository. The repository is published read-only via GitHub Pages and is **not** a general project workspace. Only persona definitions, skill cards, scenario playbooks, supporting scripts, and configuration required to serve them should be committed.

## 2. Directory Layout

Codex Tools repositories expose a small, predictable set of files so that automation can discover personas, shared instructions,
and supporting documentation without scanning unrelated content.

### 2.1 Required structure

```
/
  AGENTS.md
  README.md
  REPO_AGENTS.md
  docs/
    AGENT_ENTRYPOINT.md
    HOWTO.md
    INSTRUCTIONS.md
    PROMPT_GENERATION.md
    SPECIFICATION.md
  personas/
  skills/
  scenarios/
```

- `AGENTS.md` lives at the repository root and defines the shared baseline instructions referenced by the catalog `base_uri`.
- `README.md` provides the human-oriented overview of the published bundle and mirrors the served documentation.
- `REPO_AGENTS.md` captures repository-specific guidance that downstream automation may need to inspect explicitly.
- `docs/` contains public documentation. At minimum it must include this specification, `INSTRUCTIONS.md`, `AGENT_ENTRYPOINT.md`,
  `HOWTO.md`, and `PROMPT_GENERATION.md`.
- `/personas/` stores every persona Markdown file described in Section 3.
- `/skills/` stores reusable skill cards described in Section 4.
- `/scenarios/` stores reusable task playbooks described in Section 5.

### 2.2 Optional directories

Repositories may include additional helpers when needed:

```
(optional) crates/
(optional) scripts/
```

- `crates/` hosts the Rust workspace used to validate the persona catalog generator.
- `scripts/` holds helper shell scripts that automate container setup and validation when repositories choose to publish a
  bootstrap bundle.

## 3. Persona File Format

Each persona resides in `/personas/` as a Markdown (`.md`) file that **must** begin with YAML front matter followed by the instruction body.

### 3.1 Front-matter schema

| Field         | Type   | Required | Description                          |
| ------------- | ------ | -------- | ------------------------------------ |
| `id`          | string | yes      | Unique identifier for the persona     |
| `name`        | string | yes      | Display name (human-readable)        |
| `description` | string | no       | Short description for listings       |
| `tags`        | array  | no       | List of keywords/categories          |
| `author`      | string | no       | Who created or maintains this persona |
| `created_at`  | date   | no       | Creation date (YYYY-MM-DD)           |
| `version`     | string | no       | Version number for the persona        |

Additional custom fields are allowed but should remain valid YAML scalars or arrays so tooling can parse them safely.

### 3.2 Example persona

```markdown
---
id: delivery_engineer
name: Delivery Engineer
description: Ships production-grade Rust changes with measurable outcomes.
tags: [rust, implementation, quality]
author: QQRM
created_at: 2025-08-13
version: 0.2
---

# Delivery Engineer

## Role Snapshot
Hands-on implementer converting approved designs into reliable code.

## Responsibilities Checklist
- Break features into incremental commits with tests and documentation.
- Maintain clean dependencies and enforce agreed coding standards.

## When to Switch Away
- Architectural decisions remain open → involve the Solution Architect.

## Required Artifacts
- Implementation plan, PR checklist, and post-merge monitoring notes.

## Collaboration Signals
- Share upcoming changes with Quality and Reliability & Security engineers.
```

### 3.3 Content guidelines

- Use Markdown headings to structure the instruction body.
- Keep actionable steps concise and written in English.
- Avoid repository-specific secrets or credentials.
- Document any required tools or workflows inside the persona text.

### 3.4 Minimum instruction blocks

Every persona must include the following Markdown structure after the YAML front matter:

- `# <Role Name>` level-one heading matching the `name` field.
- `## Role Snapshot` summarizing the persona's scope and perspective.
- `## Responsibilities Checklist` detailing the non-negotiable duties for the persona.
- `## When to Switch Away` clarifying triggers for handing the task to another persona.
- `## Required Artifacts` listing the tangible outputs that must accompany each handoff.
- `## Collaboration Signals` describing coordination expectations with adjacent roles.

Optional extensions—such as collaboration guidelines, anti-patterns, or playbooks—are encouraged when they improve clarity, but they must appear under clearly labeled headings so automation can parse the required baseline consistently.

## 4. Skill File Format

Each skill resides in `/skills/` as a Markdown (`.md`) file that begins with YAML front matter followed by a short selection-oriented body. Skills are compact discovery aids: they help an agent decide whether a reusable method applies and which detailed playbook to load next.

### 4.1 Front-matter schema

| Field                  | Type   | Required | Description                                        |
| ---------------------- | ------ | -------- | -------------------------------------------------- |
| `id`                   | string | yes      | Unique identifier for the skill                    |
| `name`                 | string | yes      | Display name (human-readable)                      |
| `description`          | string | no       | Short description for listings                     |
| `tags`                 | array  | no       | List of keywords/categories                        |
| `author`               | string | no       | Who created or maintains this skill                |
| `created_at`           | date   | no       | Creation date (YYYY-MM-DD)                         |
| `version`              | string | no       | Version number for the skill                       |
| `recommended_personas` | array  | no       | Preferred personas for this method                 |
| `playbook_uri`         | string | no       | Relative URI of the detailed scenario to load next |

### 4.2 Example skill

```markdown
---
id: dependency_refresh
name: Dependency Refresh
description: Quick selector for safe toolchain and dependency updates.
tags: [maintenance, dependencies, rust]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [delivery_engineer, devops_engineer]
playbook_uri: /scenarios/DEPENDENCY_REFRESH.md
---

# Dependency Refresh Skill

## What It Is
A compact selector for safe toolchain, crate, and lockfile update work.

## When To Use
- A user requests dependency or toolchain updates.
- CI failures indicate stale lockfiles or unsupported versions.

## Default Persona
Use the `delivery_engineer` persona first. Pull in `devops_engineer` when pipeline or cache impacts dominate.

## Next Asset To Load
Load `/scenarios/DEPENDENCY_REFRESH.md` for the full execution playbook.
```

### 4.3 Minimum instruction blocks

Every skill should include the following structure after the YAML front matter:

- `# <Skill Name>` level-one heading matching the `name` field, optionally suffixed with `Skill`.
- `## What It Is` summarizing the reusable method.
- `## When To Use` listing activation triggers.
- `## Default Persona` describing the usual leading persona.
- `## Next Asset To Load` pointing to the detailed scenario playbook.

Skills should stay short. They are a discovery layer, not a replacement for full scenarios.

## 5. Scenario File Format

Each scenario resides in `/scenarios/` as a Markdown (`.md`) file that begins with YAML front matter followed by the playbook body. Scenarios provide reusable prompts for common workflows and should pair with personas when users explicitly request a named scenario.

### 5.1 Front-matter schema

| Field         | Type   | Required | Description                              |
| ------------- | ------ | -------- | ---------------------------------------- |
| `id`          | string | yes      | Unique identifier for the scenario       |
| `name`        | string | yes      | Display name (human-readable)            |
| `description` | string | no       | Short description for listings           |
| `tags`        | array  | no       | List of keywords/categories              |
| `author`      | string | no       | Who created or maintains this scenario   |
| `created_at`  | date   | no       | Creation date (YYYY-MM-DD)               |
| `version`     | string | no       | Version number for the scenario          |

### 5.2 Example scenario

```markdown
---
id: dependency_refresh
name: Dependency and Toolchain Refresh
description: Verify Rust toolchain pinning and refresh crate versions with safe updates.
tags: [maintenance, dependencies, rust]
author: QQRM
created_at: 2025-09-17
version: 0.1
---

# Dependency and Toolchain Refresh

## Goal
Keep the Rust toolchain, crates, and lockfiles on supported, current versions without breaking builds.

## When to Use
- A user requests dependency or toolchain updates.

## Inputs
- Location of `rust-toolchain.toml` or `rust-toolchain`.
- `Cargo.toml` and `Cargo.lock` for every crate.

## Execution Steps
1. Confirm the pinned Rust channel and compare with the latest stable release.
2. Enumerate crates with available patch/minor updates and note breaking major jumps.
3. Apply targeted updates (security first), refreshing the lockfile deterministically.
4. Re-run the full Rust validation loop (fmt, check, clippy, tests, release build).
5. Record notable deltas (MSRV shifts, feature flag changes, dependency removals).

## Prompt Template
Provide a concise instruction block an agent can paste to execute the scenario.
```

### 5.3 Minimum instruction blocks

Every scenario should include the following structure after the YAML front matter:

- `# <Scenario Name>` level-one heading matching the `name` field.
- `## Goal` describing the outcome.
- `## When to Use` listing triggers for this scenario.
- `## Inputs` enumerating required context or artifacts.
- `## Execution Steps` detailing the high-level procedure.
- `## Prompt Template` that can be issued to an agent without additional editing.

## 6. Catalog Generation

Tooling iterates over `/personas/`, parses YAML front matter, and produces `personas/catalog.json` that aggregates persona metadata and records the location of `AGENTS.md`. The resulting JSON is published on GitHub Pages as `personas.json`. The checked-in `personas/catalog.json` is a convenience snapshot that keeps tests deterministic and enables offline inspection; rebuild it only when intentionally changing personas or their schema.

### 6.1 Catalog schema

The catalog schema is:

```json
{
  "base_uri": "AGENTS.md",
  "personas": [
    {
      "id": "reliability_security",
      "name": "Reliability & Security Engineer",
      "description": "Protects availability, compliance, and secure delivery pipelines.",
      "tags": ["operations", "security", "resilience"],
      "author": "QQRM",
      "created_at": "2025-08-13",
      "version": "0.1",
      "uri": "https://qqrm.github.io/codex-tools/personas/RELIABILITY.md"
    }
  ]
}
```

- `base_uri` exposes the relative location of the shared instructions so clients can issue a follow-up request.
- `personas` enumerates every persona, sorted by `id`, along with the absolute Markdown URI hosted on GitHub Pages.

### 6.2 Skills catalog

Skills are indexed in `skills/catalog.json`, which is checked into the repository and published as both `skills.json` and `skills/index.json`. Example:

```json
{
  "base_uri": "AGENTS.md",
  "skills": [
    {
      "id": "dependency_refresh",
      "name": "Dependency Refresh",
      "description": "Quick selector for safe toolchain and dependency updates.",
      "tags": ["maintenance", "dependencies", "rust"],
      "author": "QQRM",
      "created_at": "2026-03-17",
      "version": "0.1",
      "recommended_personas": ["delivery_engineer", "devops_engineer"],
      "playbook_uri": "https://qqrm.github.io/codex-tools/scenarios/DEPENDENCY_REFRESH.md",
      "uri": "https://qqrm.github.io/codex-tools/skills/DEPENDENCY_REFRESH.md"
    }
  ]
}
```

Each skill entry exposes the preview metadata, the preferred personas, the follow-up playbook URI, and the absolute Markdown URI for the skill card itself.

### 6.3 Scenario catalog

Scenarios are indexed in `scenarios/catalog.json`, which mirrors the persona catalog shape but lists scenario prompts under the `scenarios` key. The file is checked into the repository and published as `scenarios.json` for consumers. Example:

```json
{
  "base_uri": "AGENTS.md",
  "scenarios": [
    {
      "id": "architecture_audit",
      "name": "Architecture Audit",
      "description": "Review modular boundaries, dependencies, and flexibility risks.",
      "tags": ["architecture", "design", "rust"],
      "author": "QQRM",
      "created_at": "2025-09-17",
      "version": "0.1",
      "uri": "https://qqrm.github.io/codex-tools/scenarios/ARCHITECTURE_AUDIT.md"
    }
  ]
}
```

### 6.4 Discovery manifest

GitHub Pages publishes a root discovery manifest at `/` (served from `index.json`). The same payload is also available at `entrypoint.json` for clients that prefer an explicit filename. The manifest lists:

- the baseline documents (`AGENTS.md`, `ENTRYPOINT.md`, `docs/HOWTO.md`, prompt-generation guide);
- the typed catalogs (`personas.json`, `skills.json`, `scenarios.json`);
- the support catalogs (`docs/index.json`, `scripts/index.json`, `workflows/index.json`);
- every published root Markdown file, shared doc, persona file, skill file, scenario file, shell script, and workflow path.

This allows agents to start with a single lightweight request, then fetch only the files they need.

### 6.5 Delivery model

Clients should begin by fetching `/` or `index.json` to discover the current published inventory. From there, the recommended sequence is:

1. fetch `AGENTS.md`;
2. fetch `docs/HOWTO.md`;
3. fetch `personas.json` and select one persona;
4. fetch `skills.json` and select one or more methods;
5. fetch `scenarios.json` only when the chosen skill or explicit user request requires the longer playbook.

The typed persona index points to the shared baseline instructions through `base_uri`; after reviewing the catalogs, an agent issues targeted requests for only the Markdown bodies it needs. This keeps the initial context footprint small while still providing a consistent entry point for automation. Requests to `/catalog.json` should be treated as configuration errors.

## 7. API Endpoints

GitHub Pages exposes the repository at `https://qqrm.github.io/codex-tools/`. Clients rely on the following endpoints:

- **Base discovery manifest:** `GET /` or `GET /index.json`.
- **Explicit alias for the same manifest:** `GET /entrypoint.json`.
- **Skill catalog:** `GET /skills.json` or `GET /skills/index.json`.
- **Catalog and base instructions:** `GET /personas.json`.
- **Incorrect legacy path:** `GET /catalog.json` returns `404 Not Found` and indicates a misconfigured client.
- **Baseline instructions only:** `GET /AGENTS.md`.
- **Human-readable bootstrap guidance:** `GET /ENTRYPOINT.md`.
- **Task-selection guide:** `GET /docs/HOWTO.md`.
- **Docs catalog:** `GET /docs/index.json`.
- **Published shared docs:** `GET /docs/{name}.md`.
- **Full persona:** `GET /personas/{id}.md`.
- **Full skill card:** `GET /skills/{id}.md`.
- **Scenario catalog:** `GET /scenarios.json`.
- **Full scenario or supplemental guide:** `GET /scenarios/{id}.md`.
- **Scripts catalog:** `GET /scripts/index.json`.
- **Published shell scripts:** `GET /scripts/{name}.sh`.
- **Workflows catalog:** `GET /workflows/index.json`.
- **Published workflows:** `GET /workflows/{name}.yml`.

The published shell scripts are for Codex Web or other ephemeral remote environments that need static bootstrap entrypoints. Local agents should prefer repository-local setup instructions or direct local installation instead of treating these scripts as mandatory.

## 8. Extensibility and Tooling

- Add new personas by committing additional Markdown files under `/personas/` with the required front matter.
- Add new skills by committing additional Markdown files under `/skills/` plus the corresponding entry in `skills/catalog.json`.
- Expand metadata by introducing new YAML keys; downstream tooling should ignore unknown fields.
- The Rust workspace under `crates/` regenerates `personas/catalog.json` via `cargo run --release`; the GitHub Pages deployment publishes the result as `personas.json` and packages the broader discovery manifests as `index.json` and `entrypoint.json`, plus the support catalogs under `/docs/`, `/scripts/`, `/workflows/`, and `/skills/`.

## 9. Relationship to README

`README.md` provides a high-level overview and onboarding notes, including the detailed bootstrap expectations referenced in Section 10. This specification remains the canonical source for persona requirements, schemas, and delivery expectations.

## 10. Bootstrap Bundle Reference

The persona specification tracks only the minimum guarantees required for the catalog and documentation. Repositories that ship
bootstrap tooling must continue to publish it under `/scripts/` as noted in Section 2.2. Detailed bootstrap behavior, script
descriptions, and mirroring guidance are documented in `README.md` under “Bootstrap Script Architecture,” which now serves as the
authoritative reference for those workflows. These workflows are intended for Codex Web or other ephemeral remote environments, not as the default path for local agents.
