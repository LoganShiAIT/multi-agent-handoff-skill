# Example Explore Handoff Output

```markdown
## Exploration Result
- Topic: API auth intermittent 401 after token refresh
- Checked: README, package manifest, `src/auth/client.ts`, `tests/auth-client.test.ts`
- Key findings: The retry path exists and token refresh is triggered, but the retry request may reuse stale headers.
- Task shape: Focused single bug investigation with one likely follow-up test.
- Handoff recommendation: light
- Suggested next action: Create `HandoffDocs/light/api-auth-investigation.md` with `/inithandoff --light api-auth-investigation`, then add the regression test.
```
