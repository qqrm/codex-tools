---
id: devsecops_audit
name: DevSecOps Audit
description: Quick selector for pipeline security, secrets handling, and supply-chain hardening reviews.
tags: [security, devsecops, compliance]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [devops_engineer, reliability_security]
playbook_uri: /scenarios/DEVSECOPS_AUDIT.md
---

# DevSecOps Audit Skill

## What It Is
A reusable skill for checking secret handling, dependency trust, workflow permissions, artifact integrity, and CI/CD security controls.

## When To Use
- Pipelines touch production or sensitive environments.
- Workflow permissions or third-party actions need review.
- Supply-chain or secret exposure risk is a primary concern.

## Default Persona
Use `devops_engineer` for delivery pipelines and `reliability_security` when the review is primarily risk, compliance, or operational security driven.

## Next Asset To Load
Load `/scenarios/DEVSECOPS_AUDIT.md` for the full execution playbook.
