---
name: subagent-workflow
description: Break a task into parallel subagent workloads, assign each workload to an appropriate agent type, keep the main thread moving on the critical path, wait only when blocked, and consolidate results back into one answer. Use when the user explicitly asks to use subagents, spawn agents, delegate in parallel, run multiple agents concurrently, split work one-agent-per-item, or otherwise requests parallel agent execution.
---

# Subagent Workflow

Decompose explicit parallel-agent requests into bounded subproblems, assign them to the right agents, and integrate the results without duplicating work or creating avoidable merge conflicts.

## Decide Whether To Delegate

Delegate only after deciding what the main thread should do immediately.

Use subagents for:
- Read-heavy exploration across independent files or questions
- Batch-shaped work where each item can be handled in isolation
- Independent implementation tasks with disjoint write scopes
- Validation passes that can run while implementation continues

Do not delegate:
- The immediate blocking task on the critical path
- Multiple agents into the same files unless overlap is intentionally managed
- Tiny tasks that are faster to do directly
- Work that depends on private reasoning from the main thread

## Plan Before Spawning

Write a short internal plan that states:
- The final outcome you need
- The immediate next step you will do locally
- Which sidecar tasks can run in parallel without blocking that step
- The expected output from each subagent

If the task is not meaningfully parallelizable, do not spawn agents.

## Choose The Right Agent

Use `explorer` for:
- Specific codebase questions
- Fast read-only inspection
- Locating files, call paths, ownership, or likely bug sites

Use `worker` for:
- Concrete implementation tasks
- Test additions or targeted fixes
- Bounded refactors with a clearly assigned write set

Reuse an existing agent when follow-up work depends on its prior context. Spawn a new one when the task is independent.

## Write Strong Subtasks

Every delegated prompt should include:
- The concrete task
- The expected deliverable
- The file or module ownership when code changes are allowed
- A reminder that the agent is not alone in the codebase and must avoid reverting others' edits

For worker prompts, explicitly name the allowed write scope. Example:

```text
Implement the failing test fix in /path/to/module_a only. You are not alone in the codebase; do not revert others' changes, and adjust to existing edits if needed. Return a short summary and list the files you changed.
```

For explorer prompts, ask one narrow question per agent when possible. Example:

```text
Inspect the authentication flow and identify where token refresh failures are surfaced to the UI. Return the relevant files and a concise explanation.
```

## Run In Parallel

Spawn independent agents together, then continue local work immediately.

Good parallel patterns:
- Multiple explorers answering different codebase questions
- Multiple workers editing different modules
- One worker implementing while another validates tests or logs

Bad parallel patterns:
- Two workers editing the same file without a strict split
- Sending the same unresolved task to multiple agents
- Waiting immediately after spawning when useful local work remains

## Wait Sparingly

Wait only when the next critical-path action depends on an agent result.

Prefer this sequence:
1. Spawn sidecar agents.
2. Do the next local blocking step.
3. Integrate any finished results.
4. Wait only if still blocked.

When you do wait, wait for the smallest set of agents that can unblock the next step.

## Integrate Results

When agents finish:
- Read the result before acting
- Trust concise explorer findings unless there is a clear reason to verify
- Review worker diffs before building on them
- Resolve overlaps locally instead of bouncing the same problem back out

Summarize the combined outcome in the main thread. Include:
- What each agent contributed
- Any conflicts or assumptions
- The final integrated result

## Forward-Testing This Skill

When validating this skill itself, use fresh subagents and avoid leaking the intended answer.

Prompt style:

```text
Use $subagent-workflow at /absolute/path/to/subagent-workflow to split this task into parallel agent work, execute it, and return a consolidated result: <task>
```

Good validation tasks:
- A code review with multiple independent areas
- A repo exploration request spanning several subsystems
- A bug task where one agent writes the regression test and another investigates the fix path, if file overlap is controlled

Avoid validation setups where the test prompt includes your diagnosis, intended fix, or hidden expectations.
