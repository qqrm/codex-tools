# How To Use Codex Tools

This repository is a shared prompt bundle for agents. Start at the published base URL, then load only the pieces needed for the current task.

## Cold-Start Order

1. Fetch `/` or `/index.json` to discover the current bundle shape.
2. Load `AGENTS.md` for the non-negotiable baseline.
3. Load this `HOWTO.md` for selection rules.
4. Pick one persona from `personas.json`.
5. Pick one or more skills from `skills.json` when a reusable method matches the task.
6. Load the full scenario playbook from `scenarios.json` only when the chosen skill or the user request requires the longer execution flow.

## How To Choose A Persona

Use exactly one primary persona for the dominant mode of the task:

- `analyst` for discovery, requirements, prioritization, and stakeholder framing.
- `architect` for system design, boundaries, contracts, and technical direction.
- `delivery_engineer` for hands-on implementation and production Rust changes.
- `devops_engineer` for CI/CD, caching, releases, pipeline safety, and delivery automation.
- `quality_engineer` for testing strategy, release gates, and coverage quality.
- `reliability_security` for operational resilience, incident readiness, and security posture.

Switch personas only when the task focus actually changes.

## How To Choose A Skill

Skills are short previews of reusable techniques. Use them to answer:

- what kind of review or method applies here;
- when that method should be activated;
- which persona should usually lead it;
- which full scenario playbook should be loaded next.

Use a skill when the task matches a known pattern such as architecture audit, dependency refresh, CI review, devsecops audit, performance review, or test coverage review.

## Skills vs. Scenarios

- `skills/` are compact selection cards.
- `scenarios/` are full execution playbooks.

The normal flow is:

1. choose a persona;
2. choose a skill;
3. if needed, load the corresponding scenario for the detailed prompt and step sequence.

## Docs vs. Skills

- `docs/` explain shared policy, specs, tools, and bootstrap behavior.
- `skills/` help decide which reusable method to apply right now.

Load docs when you need reference material. Load skills when you need task selection help.

## Bootstrap Script Rule

`BaseInitialization.sh`, `FullInitialization.sh`, and `PretaskInitialization.sh` are intended for Codex Web / ephemeral remote environments where static bootstrap scripts are needed. They stay published as direct URLs under `/scripts/`, but they are intentionally outside the cold-start discovery manifest and are not part of the default local-agent flow.

Local agents should not treat these scripts as their default path. For a local agent:

- assume the environment is already configured, or
- install missing tools directly and locally when needed, or
- follow repository-local setup instructions instead of remote bootstrap scripts.

## Default Operating Model

- Prefer the smallest set of prompts that fully cover the task.
- Do not load every persona, skill, or scenario up front.
- Prefer repository-local instructions over this shared bundle when they conflict.
- End with:
  - what changed
  - what was validated
  - what remains uncertain
