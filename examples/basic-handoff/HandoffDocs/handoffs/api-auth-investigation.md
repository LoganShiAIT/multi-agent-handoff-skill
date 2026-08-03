---
slug: api-auth-investigation
status: in-progress
owner: Codex session A
updated: 2026-07-02
branch: main
---

# API Auth Investigation

> **State** Intermittent 401s narrowed to retry header reuse after token refresh.
> **Next** Add a focused test asserting the retry request carries the refreshed token.
> **Blocked** none

## Scope
- Goal: Explain why authenticated API calls return intermittent 401 responses.
- Out of scope: Login UI, provider configuration.
- Done when: The failure is reproduced by a test that pins the cause.

## Context
- Must read: `src/auth/client.ts`, `tests/auth-client.test.ts`
- Optional: `HandoffDocs/artifacts/api-auth-investigation/test-results/20260702-101100-auth-client.txt`
- Do not read: `HandoffDocs/archive/`, `HandoffDocs/study/`, other execution handoffs, unrelated source folders

## Log
- 2026-07-02 The refreshed token is stored but the retry still sends the original Authorization header. Cause is stale retry headers, not provider-side token expiry.

## Artifacts
- `HandoffDocs/artifacts/api-auth-investigation/test-results/20260702-101100-auth-client.txt`: failing run showing the 401 on retry.
