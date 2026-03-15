# Commit Instructions

Follow these rules unless repository-specific instructions override them.

## Commit only coherent work
- Commit only intentional, relevant, understood changes.
- Do not mix unrelated concerns in one commit.
- Do not commit broken code unless the task explicitly requires an incomplete checkpoint.

## Keep the diff clean
- Remove debug prints, temporary hacks, commented-out code, and accidental edits.
- Do not include unrelated formatting churn, generated files, or noise unless required.

## Tell the truth
- The commit message must match the actual diff.
- Do not use vague messages like `wip`, `misc`, `fix stuff`, or `updates`.

## Message format
Use:

<type>: <short imperative summary>

Allowed types:
- feat
- fix
- refactor
- docs
- test
- build
- ci
- perf
- chore

Examples:
- `fix: preserve task state after restart`
- `feat: add incremental snapshot indexing`
- `refactor: isolate Hyper-V bootstrap logic`

## Before committing
Confirm all of the following:
- scope is correct;
- diff is intentional;
- relevant checks were run;
- no temporary junk remains;
- repository is left in a coherent state.

## Agent rule
Prefer one good commit per completed batch of work.
If blocked, do not hide the blocker behind an optimistic commit message.
