---
name: firebase-hosting-deployment
description: Deploy a web app to Firebase Hosting with branch confirmation, optional build verification, and deploy output checks. Use when asked to publish a site to Firebase Hosting, confirm the target branch before deploying, run a build step first if the project has one, or handle Firebase CLI deployment errors.
---

# Firebase Hosting Deployment

## Workflow

1. Check the current git branch and whether the worktree is clean.
2. Ask the user which branch to deploy from before running any deploy command.
3. If the user chooses a different branch, stash only if needed, switch branches, and confirm the switch.
4. Ask whether the project has a build step. If it does, run the appropriate build command and stop on failure.
5. Run `firebase deploy --only hosting` or `firebase deploy --only hosting:[site-name]` if the user specifies a site.
6. Confirm success from the CLI output by finding the Hosting URL.
7. If the branch was switched, offer to switch back and restore any stashed changes.

## Guardrails

- Never assume the target branch.
- Never deploy without explicit user confirmation.
- Never skip the build step if the project has one.
- Stop immediately on build or deploy errors.
- If `firebase` is missing, instruct the user to install `firebase-tools` and run `firebase login`.

## Notes

- This skill is deploy-only. Do not commit, merge, or force push.
- Prefer the repository's documented build command when one exists.
