---
name: webapp-compile-run-check
description: Verify that a web application compiles and starts without runtime startup errors, then report actionable fixes when failures occur. Use when users ask to make a website/app build cleanly, run locally without issues, or troubleshoot compile/startup problems in React, TypeScript, Vite, or similar Node-based web projects.
---

# Webapp Compile Run Check

Run a minimal, deterministic health check for Node-based web apps, prioritizing fast feedback and concrete fixes.

## Workflow

1. Detect package manager from lockfile.
- Use `npm` for `package-lock.json`.
- Use `pnpm` for `pnpm-lock.yaml`.
- Use `yarn` for `yarn.lock`.

2. Install dependencies only if required.
- If `node_modules` is missing or install is explicitly requested, run install.
- Do not upgrade dependencies unless requested.

3. Run compile/build check.
- Preferred command order:
  - `npm run build`
  - `pnpm build`
  - `yarn build`
- If no build script exists, run TypeScript check if present (`tsc --noEmit`) and note limitation.

4. Run startup boot check.
- Start dev server with explicit host and port when possible.
- Treat a successful boot banner (`ready`, `listening`, or equivalent) as pass.
- Stop the process after boot confirmation.

5. If failures occur, fix in smallest safe change.
- Prefer direct fixes to configuration, imports, and type errors.
- Keep behavior unchanged unless a behavior change is required to resolve the failure.

6. Re-run only the failed step after a fix.
- Avoid full retest loops unless requested.

## Output Format

Return concise status:
- Build: pass/fail
- Startup: pass/fail
- Fixes applied: bullet list with file paths
- Remaining risks: only if unresolved issues remain

## Guardrails

- Do not run exhaustive checks (lint/test/e2e) unless requested.
- Do not perform dependency major-version migrations unless requested.
- Do not modify unrelated files.
- If a command is missing in scripts, state the gap and provide the exact script to add.

## ZPick Project Defaults

In this repository, prefer:
- Build: `npm run build`
- Dev boot check: `npm run dev -- --host 127.0.0.1 --port 4173`
- Tests only on explicit request: `npm test`
