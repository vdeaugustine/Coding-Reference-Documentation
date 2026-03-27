---
name: merge-conflict-minimal-resolver
description: Resolve Git merge conflicts with a least-invasive strategy that preserves existing behavior and as much content as possible. Use when files contain conflict markers, rebase/cherry-pick/merge stops on conflicts, or a branch needs safe conflict resolution that synthesizes both sides where compatible and chooses the best side only when coexistence is not possible.
---

# Merge Conflict Minimal Resolver

Apply conservative conflict resolution that keeps user intent and minimizes unnecessary edits.

## Core Principles

1. Preserve before replacing.
2. Change only conflicted regions unless a tiny adjacent edit is required to compile.
3. Keep both sides when semantics can coexist.
4. Prefer synthesis over taking one side wholesale.
5. Choose one side only for true mutual exclusivity.
6. Keep formatting, ordering, and naming consistent with local file style.
7. Never drop behavior silently; explain tradeoffs in the final summary.

## Workflow

1. Identify all conflicted files (`git status`, search for `<<<<<<<`, `=======`, `>>>>>>>`).
2. Resolve each conflict region independently; avoid large-file rewrites.
3. Classify each conflict:
   - Non-overlapping intent: both sides add/change different concerns.
   - Same intent, different implementation: combine only the compatible parts.
   - Direct incompatibility: both sides cannot be active simultaneously.
4. Apply the least-invasive merge strategy:
   - Keep both with minimal composition for non-overlapping intent.
   - Synthesize a hybrid for same-intent differences.
   - Select one side only for direct incompatibility.
5. Run targeted validation (build/tests/lint relevant to touched code).
6. Stage files and summarize exactly what was kept, synthesized, and chosen.

## Conflict Decision Rules

Use this order:

1. Coexistence check
   - Keep both if behavior remains valid and non-duplicative.
2. Minimal synthesis check
   - Combine the smallest set of lines required to retain both intents.
3. Irreconcilable check
   - If both cannot coexist, pick the option with the better score:
     - Correctness and testability first.
     - Lower regression risk second.
     - Better alignment with surrounding architecture and naming third.
     - Smaller behavioral surprise for users fourth.

Avoid "take ours/theirs" for an entire file unless the file is generated/lockfile and project convention supports that choice.

## Merge Patterns

### Independent additions on both sides
Keep both blocks, preserve existing order where meaningful, and avoid renaming unless required.

### API signature mismatch
Prefer the signature used by current call sites, then incorporate compatible improvements from the other side in implementation.

### Deletion vs modification
If modified behavior is still required by active callers/tests, keep and adapt the modified version. If feature was intentionally removed and no active dependency remains, accept deletion.

### Config/version conflicts
Prefer the version/config that keeps the project building now; then merge compatible config keys from both sides.

### Formatting-only vs logic change
Keep the logic change; reapply formatting style afterward.

## Guardrails

1. Remove all conflict markers before finishing.
2. Keep diffs surgical; do not opportunistically refactor.
3. Keep comments and docs if still accurate; update only where behavior changed.
4. Preserve public interfaces unless conflict resolution requires a coordinated update.
5. If a choice is ambiguous, document the assumption and pick the safest reversible option.

## Validation Checklist

1. Confirm no markers remain: `rg -n '^(<<<<<<<|=======|>>>>>>>)'`.
2. Run the smallest reliable verification set for touched components.
3. Ensure no duplicate logic was introduced by combining both sides.
4. Ensure imports/includes/build settings are consistent after synthesis.
5. Verify `git diff --staged` is conflict-focused and minimally invasive.

## Output Template

Report conflict resolution using:

1. Files resolved.
2. For each file: what was kept from each side.
3. Where synthesis occurred and why.
4. Where one side was chosen and why coexistence failed.
5. Validation commands run and outcomes.
