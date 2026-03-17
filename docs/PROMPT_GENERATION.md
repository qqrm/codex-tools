# Prompt Generation for Agentic Execution

This document defines how to generate context-efficient prompts for an execution agent.

Use the root manifest at `/` or `index.json` to discover this document when the repository is consumed over GitHub Pages. `entrypoint.json` remains a published alias for the same manifest. In that remote flow, the planner should usually inspect `AGENTS.md`, `docs/HOWTO.md`, one persona, and only the smallest matching set of skills or scenarios before writing the execution prompt.

## Purpose

The planner model already has the repository bundle and enough context to understand the project. The execution agent does not need a full repo retelling. The planner should compress context into a clear task packet.

## Roles

- Planner: understands the broader context, chooses scope, and writes the execution prompt.
- Execution agent: implements the task, follows repository instructions, gathers local code context, and validates results.

## Core Principle

Do not restate the whole repository. Provide only the information required to complete one coherent batch of work.

## A Good Execution Prompt Must Include

1. **Goal**
   - one short paragraph describing the intended outcome.
2. **Scope**
   - the exact area to touch;
   - what is intentionally out of scope.
3. **Constraints**
   - invariants that must not be broken;
   - required compatibility or behavior guarantees.
4. **Pointers**
   - likely files, modules, commands, or entrypoints;
   - enough to reduce search cost without pretending to know every detail.
   - if the work depends on shared prompt assets, specify the exact persona, skill, and scenario files to load instead of saying "use Codex Tools generally".
5. **Validation**
   - the checks that must be run.
6. **Output Contract**
   - what changed;
   - what was validated;
   - what remains uncertain.

## What To Avoid

Do not include:
- long repository summaries;
- generic engineering philosophy already covered by baseline instructions;
- repeated warnings copied from global guidance;
- speculative architecture essays unrelated to the task;
- line-by-line implementation scripts when local engineering judgment is still useful.

## Autonomy Budget

The execution agent should:
- read the local repository instructions and relevant files;
- make reasonable low-risk assumptions;
- complete one coherent batch end-to-end;
- install missing local tools when safe and reproducible.

The execution agent should not:
- widen product scope;
- silently change architecture;
- hide blockers;
- fake validation or completion.

## Prompt Shape

Use this default structure:

```text
Task type: execution

Goal:
<desired outcome>

Scope:
<what to change>
<what not to change>

Constraints:
<invariants, compatibility, behavior limits>

Pointers:
<files, commands, areas worth checking>

Validation:
<required checks>

Return only:
- what changed
- what was validated
- what remains uncertain
```

## Compression Rules

- Prefer one dense task packet over many tiny follow-up messages.
- Mention only task-relevant files and concepts.
- Reuse repository instructions instead of copying them into the prompt.
- Split the task only when one batch would mix unrelated concerns or hide risk.
- Use stricter wording for execution than for planning, but do not over-constrain harmless local decisions.

## When To Escalate Instead of Writing an Execution Prompt

Do not generate an execution prompt yet if:
- the task is actually architectural discovery;
- success criteria are still unclear;
- repository state is missing;
- the requested change spans multiple unrelated domains;
- the main problem is semantic ambiguity rather than implementation.

In that case, first generate a discovery or clarification packet.

## Bootstrap Script Note

`BaseInitialization.sh`, `FullInitialization.sh`, and `PretaskInitialization.sh` are for Codex Web or other ephemeral remote environments that need static bootstrap entrypoints. Do not include them in a local-agent execution prompt unless the task explicitly targets remote bootstrap behavior.
