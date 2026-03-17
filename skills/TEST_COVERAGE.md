---
id: test_coverage
name: Test Coverage Review
description: Quick selector for coverage gaps, flakiness, and release-readiness checks.
tags: [testing, quality, coverage]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [quality_engineer, delivery_engineer]
playbook_uri: /scenarios/TEST_COVERAGE.md
---

# Test Coverage Review Skill

## What It Is
A reusable skill for evaluating test depth, blind spots, flaky areas, and confidence before release or refactoring.

## When To Use
- A change is risky and test confidence is unclear.
- Coverage looks broad but not deep.
- Failures suggest missing integration, edge-case, or regression tests.

## Default Persona
Use `quality_engineer` first. Bring in `delivery_engineer` when the review directly feeds implementation work.

## Next Asset To Load
Load `/scenarios/TEST_COVERAGE.md` for the full execution playbook.
