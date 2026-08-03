---
slug: api-auth-investigation
status: in-progress
updated: 2026-07-02
---

# API Auth Investigation

> **State** Likely cause is stale retry headers after token refresh.
> **Next** Add a focused regression test for retry headers after refresh.
> **Blocked** none

## Context
- Must read: `src/auth/client.ts`, `tests/auth-client.test.ts`
- Do not read: project-wide handoff state, unrelated source folders

## Log
- 2026-07-02 The retry after a 401 reuses the original Authorization header instead of the refreshed one.
