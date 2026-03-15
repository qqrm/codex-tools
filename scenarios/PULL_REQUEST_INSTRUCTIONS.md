# Pull Request Instructions

Follow these rules unless repository-specific instructions override them.

## Goal
Open focused, reviewable, truthful pull requests.

## Core rules
- One PR = one coherent change set.
- Do not mix unrelated work.
- Do not hide behavior changes under `cleanup` or `refactor`.
- Keep the description aligned with the actual diff, not the original plan.
- Be explicit about limits, risks, and deferred work.

## PR title
Use a short, specific title.

Examples:
- `Preserve task state across restarts`
- `Add incremental indexing for repo snapshots`
- `Isolate Hyper-V setup into dedicated bootstrap flow`

## PR description
Use this structure:

## Summary
What changed.

## Problem
What was wrong or missing before.

## Solution
How the new behavior works.

## Scope
What is included and what is intentionally not included.

## Validation
What checks were actually run.

## Risks
What remains uncertain or deserves reviewer attention.

## Validation rules
- Only list checks that were actually run.
- Do not write `tested` or `should work`.
- Include manual verification when relevant.

## Agent rule
State blockers, gaps, and deferred work explicitly.
If the PR is larger than ideal, explain why it was not split safely.
