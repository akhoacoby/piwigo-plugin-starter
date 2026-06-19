# Commits & Pull Requests

## Workflow
- Commit / push ONLY when the user asks.
- Never commit on the default branch — create a feature branch first.
- Run lint + verification (`11-testing.md`) before committing.
- Check `git status` before committing; keep changes minimal and focused on the task.

## Commit messages
- Imperative summary line (≤ ~72 chars), then a body explaining the WHY (the problem and the approach).
- Bug/feature raised from a user report — add a trailer:
  ```
  git commit --trailer "Reported-by:<name>"
  ```
- Tied to a GitHub issue — add a trailer:
  ```
  git commit --trailer "Github-Issue:#<number>"
  ```
- Group related changes; don't mix unrelated edits in one commit.

## Pull requests
- Title: concise summary. Body: high-level description of the problem and how it's solved — avoid line-by-line code detail unless it adds clarity.
- Reference the issue it closes.
- Add the project's designated reviewer (configure per repository).
- Ensure CI / lint is green before requesting review.

> Note: this project's standing commit-message footer policy is configured at the harness level; align trailers here with that policy (see the chat note on co-authored-by).
