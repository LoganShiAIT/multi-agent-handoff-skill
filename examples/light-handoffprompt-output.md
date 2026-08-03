# Example On-Demand Light Handoff Prompt Output

This text is emitted only after an explicit prompt-generation request and is not stored in the light handoff.

```markdown
You are working from light handoff `api-auth-investigation`.

First read `HandoffDocs/light/api-auth-investigation.md`.

Goal:
- Check why API auth sometimes returns 401 after token refresh.
- Keep the work scoped to API client retry behavior.

Scope:
- Update only `HandoffDocs/light/api-auth-investigation.md` before returning.
- Do not create full handoff index, artifacts, archive, study notes, or cleanup records unless the user explicitly asks.
- If the work exceeds this light handoff's scope, record the blocker and return without silently expanding the file.

Before returning:
- Refresh the status block and frontmatter `updated`.
- Append to `Log` only what cannot be derived from code, specs, or git.

Return:
- What you changed or found
- Files touched
- Verification run
- Remaining blockers
```
