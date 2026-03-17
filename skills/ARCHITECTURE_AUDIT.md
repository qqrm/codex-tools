---
id: architecture_audit
name: Architecture Audit
description: Quick selector for structural reviews, dependency analysis, and boundary cleanup.
tags: [architecture, design, rust]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [architect, analyst]
playbook_uri: /scenarios/ARCHITECTURE_AUDIT.md
---

# Architecture Audit Skill

## What It Is
A reusable skill for reviewing module boundaries, interfaces, dependency direction, and refactor opportunities.

## When To Use
- System design feels brittle or tightly coupled.
- New work keeps crossing too many module boundaries.
- You need a technical review before major implementation starts.

## Default Persona
Use the `architect` persona first. Pull in `analyst` if the audit must reconnect design choices to business priorities.

## Next Asset To Load
Load `/scenarios/ARCHITECTURE_AUDIT.md` for the full execution playbook.
