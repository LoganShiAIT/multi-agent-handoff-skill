# API Auth Investigation

## Metadata
- Slug: api-auth-investigation
- Owner / Agent: Codex session A
- Status: in-progress
- Created: 2026-07-02 09:58
- Last Updated: 2026-07-02 10:12
- Branch / Worktree: main
- Related Files: `src/auth/client.ts`, `tests/auth-client.test.ts`

## Mission
- Goal: Identify why authenticated API calls return intermittent 401 responses in the sample service.
- Out of Scope: Rewriting the login UI or changing provider configuration.
- Success Criteria: A follow-up agent can reproduce the failure, understand the likely cause, and continue from the next focused test.

## Context Panel
- Slot discusses: Intermittent 401 responses after token refresh in the sample API client.
- Required files to read: `src/auth/client.ts`, `tests/auth-client.test.ts`
- Optional files to read only if needed: `HandoffDocs/artifacts/api-auth-investigation/test-results/20260702-101100-auth-client.txt`
- Do not read by default: `HandoffDocs/archive/`, `HandoffDocs/study/`, other task handoffs, unrelated source folders.

## Context Packet
- User request: "Investigate intermittent API auth failures after token refresh."
- Relevant project facts: The API client refreshes tokens on demand and retries once after a 401.
- Commands already run: `npm test -- auth-client`
- Files already inspected: `src/auth/client.ts`, `tests/auth-client.test.ts`

## Progress Log
- 2026-07-02 10:05: Confirmed the retry path runs after the first 401.
- 2026-07-02 10:12: Found that the refreshed token is stored but the retry still uses the original Authorization header.

## Findings and Decisions
- The likely defect is stale retry headers, not provider-side token expiry.
- Keep the task focused on API client retry behavior.

## Artifacts
- Reports: none
- Test scripts: none
- Test results: `HandoffDocs/artifacts/api-auth-investigation/test-results/20260702-101100-auth-client.txt`
- Other byproducts: none

## Study Notes
| Path | Topic | Key Lesson | Created |
| --- | --- | --- | --- |

## Compacted History
| Record | Covered Range | Summary | Created |
| --- | --- | --- | --- |

## Extra File Index
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

## Handoff Back
- Current state: Failure is narrowed to retry header reuse after token refresh.
- Next recommended step: Add a focused test that asserts the retry request uses the refreshed token.
- Risks / blockers: No blocker; avoid changing unrelated login behavior.
- Prompt for the next agent: Continue `api-auth-investigation` by adding a regression test around refreshed retry headers, then patch only the API client retry path.
