# Instructions

The published persona site is available at:

```text
https://qqrm.github.io/codex-tools/
```

- `GET /` or `GET /index.json` — retrieve the cold-start discovery manifest for the published bundle.
- `GET /entrypoint.json` — retrieve the same discovery manifest via a stable alias.
- `GET /skills.json` — retrieve the combined catalog of baseline guides, shared docs, and scenario playbooks.
- `GET /personas.json` — retrieve the persona catalog with the `base_uri` pointer to the shared instructions. The deployment does **not** expose `/catalog.json`, so avoid requesting that legacy path.
- `GET /AGENTS.md` — fetch the shared baseline instructions referenced by `base_uri`.
- `GET /ENTRYPOINT.md` — fetch the human-readable agent bootstrap guidance referenced by `entrypoint.json`.
- `GET /docs/index.json` — retrieve the docs catalog for shared guides and specifications.
- `GET /docs/{name}.md` — fetch any published shared guidance document under `/docs/`.
- `GET /personas/{id}.md` — retrieve the complete descriptor for the persona with the given `id`.
- `GET /scenarios.json` — retrieve the scenario catalog for reusable execution playbooks. Each entry links to Markdown prompts stored alongside personas.
- `GET /scenarios/{id}.md` — retrieve the scenario Markdown requested by the catalog entry.
- `GET /scripts/index.json` — retrieve the shell-script catalog for bootstrap and validation entry points.
- `GET /scripts/{name}.sh` — fetch any published bootstrap or validation shell script.
- `GET /workflows/index.json` — retrieve the workflow catalog for published CI/CD definitions.
- `GET /workflows/{name}.yml` — inspect the workflows shipped with the published bundle.

Clients that need a complete inventory should start with `/` or `index.json` and treat `skills.json`, `personas.json`, and `scenarios.json` as layered catalogs exposed by that root manifest. This is important because the repository also publishes supplemental Markdown guides, script entry points, and workflow definitions that are intentionally outside the typed persona and scenario catalogs.

# Response Guidelines

- Share analytical findings and status updates directly in the conversation unless the task explicitly requires repository artifacts.
- Avoid committing ad-hoc reports or chat transcripts into the repository unless they are part of the deliverable specification.
- When a user explicitly asks to run a scenario (e.g., architecture audit, dependency refresh), fetch it from the published catalog and follow the instructions alongside the selected persona.
