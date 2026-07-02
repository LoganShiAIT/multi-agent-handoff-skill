# API Auth Investigation

## Intent
- User request: "Check why API auth sometimes returns 401 after token refresh."
- Goal: Preserve enough context for one focused follow-up session.
- Scope: Inspect API client retry behavior only; do not manage project-wide handoff state.

## Current Understanding
- Key facts: The retry path runs after the first 401, but the retry appears to reuse the original Authorization header.
- Files inspected: `src/auth/client.ts`, `tests/auth-client.test.ts`
- Commands run: `npm test -- auth-client`

## Progress
- 2026-07-02 10:12: Narrowed the likely issue to stale retry headers after token refresh.

## Next
- Recommended next step: Add a focused regression test for retry headers after refresh.
- Verification: Re-run `npm test -- auth-client`.
- Handoff prompt: Continue from `HandoffDocs/light/api-auth-investigation.md`; keep the task scoped to API client retry behavior unless artifacts or cross-session coordination make full handoff tracking necessary.
