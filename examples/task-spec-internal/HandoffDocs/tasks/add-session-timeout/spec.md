# Add Session Timeout Specification

## Requirements
- Expire an authenticated session after the configured inactivity period.
- Redirect an expired session to authentication on the next protected request.

## Constraints
- Preserve current behavior while the timeout setting is unset.

## Acceptance Criteria
- A focused test proves expiration after the configured duration.
- A focused test proves recent activity refreshes the inactivity deadline.
