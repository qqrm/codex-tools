---
id: build_and_ci_review
name: Build and CI Review
description: Quick selector for validating build reproducibility, workflow safety, and CI quality.
tags: [ci, build, pipelines]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [devops_engineer, reliability_security]
playbook_uri: /scenarios/BUILD_AND_CI_REVIEW.md
---

# Build and CI Review Skill

## What It Is
A reusable skill for reviewing pipelines, cache strategy, build determinism, workflow correctness, and release safety.

## When To Use
- CI is flaky, slow, or outdated.
- Workflow changes need review before rollout.
- You need to validate that builds are reproducible and policy-compliant.

## Default Persona
Use the `devops_engineer` persona first. Pair with `reliability_security` when the review is security-heavy.

## Next Asset To Load
Load `/scenarios/BUILD_AND_CI_REVIEW.md` for the full execution playbook.
