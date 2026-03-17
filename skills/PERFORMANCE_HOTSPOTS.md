---
id: performance_hotspots
name: Performance Hotspots Review
description: Quick selector for CPU, allocation, and IO bottleneck investigation.
tags: [performance, profiling, rust]
author: QQRM
created_at: 2026-03-17
version: 0.1
recommended_personas: [delivery_engineer, architect]
playbook_uri: /scenarios/PERFORMANCE_HOTSPOTS.md
---

# Performance Hotspots Review Skill

## What It Is
A reusable skill for locating expensive code paths, memory churn, and throughput bottlenecks before optimizing.

## When To Use
- The system is slow, memory-heavy, or latency-sensitive.
- Profiling or performance triage is needed before coding a fix.
- Performance tradeoffs must be explained clearly before implementation.

## Default Persona
Use `delivery_engineer` for profiling and code-level optimization. Use `architect` when the bottleneck suggests a structural redesign.

## Next Asset To Load
Load `/scenarios/PERFORMANCE_HOTSPOTS.md` for the full execution playbook.
