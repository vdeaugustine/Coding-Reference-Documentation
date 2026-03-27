---
name: git-commit
description: Prepare a git commit by analyzing staged and unstaged changes, drafting a commit message from the diff, and creating the commit. Use when the user asks to commit changes, summarize work into a commit message, or wants help deciding what should be included in the commit.
---

# Git Commit

## Workflow

1. Inspect repository state first.
   - Run `git status --short`.
   - Inspect staged changes with `git diff --staged`.
   - Inspect unstaged changes with `git diff`.
2. Decide what belongs in the commit.
   - Treat staged changes as the intended commit content.
   - If unstaged changes are clearly part of the same logical change and the user asked for a commit of "what we made", stage them before committing.
   - If unrelated changes exist, leave them unstaged and call them out before committing.
3. Write the commit message from the actual diff.
   - Prefer a short imperative subject line.
   - Keep the subject specific to the change, not to the files edited.
   - Add a body only when the diff needs context, tradeoffs, or follow-up notes.
4. Create the commit.
   - Use `git commit -m "<subject>"` for simple commits.
   - Use `git commit` with a body when more detail is needed.
   - Do not amend existing commits unless the user explicitly asks.
5. Verify the result.
   - Re-run `git status --short` to confirm the tree is in the expected state.
   - Report the commit hash and the final message.

## Guardrails

- Do not discard, reset, or overwrite user changes.
- Do not stage or commit unrelated work just to make the tree clean.
- If there are no changes to commit, say so and stop.
- If the diff is ambiguous, ask for confirmation before committing.

## Output

- Return the commit hash and a one-line summary of what was committed.
