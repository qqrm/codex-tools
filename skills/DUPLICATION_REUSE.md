---
id: duplication_reuse
name: Duplication and Reuse Review
description: Quick selector for consolidation, shared abstractions, and repeated logic cleanup.
tags: [refactoring, reuse, quality]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [architect, delivery_engineer]
playbook_uri: /scenarios/DUPLICATION_REUSE.md
---

# Duplication and Reuse Review Skill

## What It Is
A reusable skill for finding repeated logic, converging shared patterns, and reducing structural copy-paste.

## When To Use
- Similar logic appears in multiple files or modules.
- Small changes require touching too many parallel implementations.
- Shared abstractions are missing or underused.

## Default Persona
Use `architect` when the change affects boundaries or abstractions. Use `delivery_engineer` when the work is mostly implementation cleanup.

## Next Asset To Load
Load `/scenarios/DUPLICATION_REUSE.md` for the full execution playbook.
