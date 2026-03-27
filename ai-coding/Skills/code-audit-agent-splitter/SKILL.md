---
name: code-audit-agent-splitter
description: Perform production-grade code audits focused on correctness, bugs, crashes, security, performance, maintainability, and best practices, then package the findings into independent, merge-safe work units for separate AI coding agents. Use when a user asks for a deep code review, audit, hardening pass, bug hunt, security/performance review, or wants findings split into copy-pasteable agent prompts with minimal file overlap.
---

# Code Audit Agent Splitter

Audit the target codebase like a senior reviewer, then transform the results into execution-ready prompts that can be handed to parallel coding agents without stepping on each other.

Default to findings-first output. Do not spend tokens on broad praise or generic summaries.

## Workflow

1. Establish scope before judging quality.
- Read enough of the codebase structure to identify modules, ownership boundaries, data flow, and risky surfaces.
- If the user supplied a subset of files, stay within that slice unless adjacent code is required to validate a finding.

2. Audit across these dimensions.
- Correctness: logic mistakes, edge cases, invalid assumptions, off-by-one errors.
- Bugs and crashes: null handling, race conditions, stale state, error handling gaps, resource leaks.
- Security: injection risks, authz/authn gaps, secrets exposure, unsafe trust boundaries, validation holes.
- Performance: unnecessary work, quadratic behavior, blocking calls, cache misses, redundant renders/queries.
- Maintainability: naming, cohesion, dead code, duplication, brittle abstractions, hidden coupling.
- Best practices: framework misuse, outdated APIs, missing invariants, poor test coverage around risky behavior.

3. Produce only defensible findings.
- Prefer findings you can tie to a concrete failure mode, exploit path, cost, or maintenance risk.
- Include file paths and line references when available.
- Mark severity as `Critical`, `High`, `Medium`, or `Low`.
- Skip nitpicks unless they materially affect reliability, safety, or long-term change cost.

4. Split work into independent groups.
- Group findings by distinct file ownership, module, or layer.
- Optimize for zero or minimal merge conflicts.
- Do not create overlapping groups that edit the same file unless there is no clean alternative.
- If two findings touch the same file, keep them in one group unless one can be resolved by tests only.

5. Write each group as a self-contained prompt for another agent.
- Assume the receiving agent has no prior context.
- State the scope, problem summary, exact files or modules to edit, and the intended outcome.
- State what the agent must not touch to avoid conflicts.
- Order issues inside the group by severity.

## Output Contract

When the user asks for grouped prompts, return:

1. A short audit summary, only if it adds useful context.
2. Then one block per work unit, wrapped in triple backticks so it is easy to copy.
3. Keep groups independent and non-overlapping.

Use this structure inside each fenced block:

```text
Group: <short title>
Scope: <files, modules, or layer this agent owns>

Severity:
- Critical: ...
- High: ...
- Medium: ...
- Low: ...

Problem Summary:
<2-5 sentence explanation of what is wrong and why it matters>

Instructions:
- <specific change 1>
- <specific change 2>
- <specific change 3>

Constraints:
- Touch only: <paths/modules>
- Do not modify: <paths/modules owned by other groups>
- Preserve: <behavioral or architectural constraints>

Definition of Done:
- <observable outcomes or tests the agent should satisfy>
```

## Grouping Rules

- Split by file ownership first.
- If file ownership is broad, split by vertical slice or feature boundary.
- Keep test-only work with the production files it validates unless the test suite is fully isolated.
- Avoid creating a “miscellaneous” group unless all findings are truly low-risk and non-overlapping.
- If there are no credible findings, say so plainly instead of inventing work.

## Review Standard

- Treat this as a production-readiness review, not a style pass.
- Prefer concrete, actionable findings over exhaustive commentary.
- Call out uncertainty when a risk depends on runtime assumptions you cannot verify.
- When evidence is partial, say `Possible` or `Likely` instead of overstating certainty.
- If the user asked for thoroughness, spend the extra effort on deeper reasoning and better decomposition, not on longer prose.

## Guardrails

- Do not propose overlapping prompts that compete for the same files unless the user explicitly wants alternative approaches.
- Do not hide high-severity issues inside a low-priority cleanup group.
- Do not instruct agents to refactor unrelated code “while there”.
- Do not pad the output with generic testing advice; tie tests to the specific problems in the group.
