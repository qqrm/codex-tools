# Agent Entrypoint

Use this repository as a shared baseline for agent work. It is not the source of truth for any specific product repository.

When accessing the published bundle over GitHub Pages, start with the base URL `/` (served from `index.json`) or with `entrypoint.json` to discover the current cold-start catalogs, Markdown guides, and workflow paths before loading individual files.

## Resolution Order

Load context in this order:
1. repository-local `AGENTS.md`
2. repository-local `CURRENT_STATE.md`
3. repository-local `DONE_CRITERIA.md`
4. this repository root `AGENTS.md`
5. `docs/HOWTO.md`
6. one matching persona from `personas/`
7. one or more matching skills from `skills/`
8. only the scenarios needed for the current task

## How To Use This Repository

- Treat the root `AGENTS.md` as the global baseline.
- Use the root manifest at `/` or `index.json` as the machine-readable inventory for published files.
- Load `docs/HOWTO.md` before selecting task assets from the shared bundle.
- Load `skills.json` when you need a compact list of reusable methods and links to the matching scenario playbooks.
- Select one persona that matches the dominant task mode.
- Select one or more skills only when a reusable method clearly matches the task.
- Load only the scenarios that directly help with the current work.
- Prefer repository-local instructions over these shared defaults when they conflict.
- Treat task-specific instructions as stronger than generic scenario guidance.

## MCP / Tooling Policy

Prefer this order when multiple tools are available:
1. repository-local search or code search for code and docs discovery
2. task memory or recent-task summaries for ongoing project history
3. browser for remote baseline docs and external references
4. shared document storage only for curated project documents

Do not fetch remote baseline files repeatedly during one task if the same content is already loaded and still valid.

## Environment Bootstrap

Published bootstrap scripts exist under `/scripts/`, but they are intentionally outside the cold-start discovery path. Load them only when the task explicitly targets Codex Web or another ephemeral remote environment that requires static setup entrypoints.

For local agents, do not default to these scripts. Prefer repository-local setup instructions or install the missing tools directly when needed.

If a required tool is missing:
- first check repository-local setup instructions and shared docs;
- install it yourself when this is safe, reproducible, and necessary to complete the task;
- otherwise surface the blocker clearly.

## Default Behavior

- work proactively, but stay within scope;
- prefer root-cause fixes over patches and workarounds;
- keep changes reviewable and coherent;
- finish with a concise factual report.
