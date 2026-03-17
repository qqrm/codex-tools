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
A reusable skill for refreshing Rust toolchains, crate versions, lockfiles, and related validation loops.

## When To Use
- Dependencies are stale or vulnerable.
- Toolchain drift needs cleanup.
- Dependabot or manual updates need a controlled review and validation pass.

## Default Persona
Use the `delivery_engineer` persona for code-facing updates. Use `devops_engineer` when CI/toolchain compatibility is the dominant concern.

## Next Asset To Load
Load `/scenarios/DEPENDENCY_REFRESH.md` for the full execution playbook.
