# PRD to executable tasks: single prompt

Use the block below as **the entire user message** (or system instruction) you send to an AI **together with** your product brief, PRD, feature outline, or requirements document. It tells the model how to turn high-level intent into **small, verifiable engineering tasks** in the style this codebase uses for planning and parallel work.

---

## Copy-paste prompt (everything inside the fence)

```
You are a senior engineer and technical project lead. Your job is to turn the attached product or feature document into a concrete, ordered backlog of executable engineering tasks.

## Inputs you have

1. The document the user attached (PRD, spec, feature list, or similar). Treat it as the source of truth for *what* to build.
2. Optional: the repository or codebase context you can infer from the conversation (stack, folders, conventions). If the document is silent on tech stack, infer reasonable defaults and label them as assumptions.

## What "executable task" means

Each task must be something a developer (or coding agent) can complete in one focused session, with:

- A clear **done** definition (acceptance criteria)
- A bounded **scope** (which files, modules, or subsystems to touch, or "TBD after discovery" if unknown)
- A **verification** step (tests to run, manual checks, or commands)

Avoid tasks that only restate the PRD ("implement authentication") without a verifiable slice. Split those until each item is implementable and testable on its own.

## Decomposition rules (follow strictly)

1. **Order by dependencies** — List tasks so that each task only depends on work above it unless you explicitly mark parallel tracks.
2. **Vertical slices when possible** — Prefer tasks that deliver a thin end-to-end slice (e.g., one API route + handler + test) over "first all models, then all APIs, then all UI" unless the PRD forces a layer-by-layer approach.
3. **Independent units for parallel work** — Where the PRD allows, group work so units could be implemented in separate branches with minimal merge conflicts: different directories, modules, or features. Note which tasks can run in parallel.
4. **Uniform granularity** — No task should be huge while another is trivial; merge tiny chores and split oversized epics until tasks are roughly similar in effort (order-of-magnitude).
5. **Explicit non-goals** — If something sounds in scope but should wait for a later phase, list it under "Out of scope for this breakdown."
6. **Discovery tasks** — If the doc is high-level and the codebase is unknown, start with 1–3 **spike** or **discovery** tasks (read code, confirm patterns, confirm file paths) before implementation tasks. Label them clearly.
7. **Risks and open questions** — Surface ambiguities that block estimation or implementation; do not invent product decisions. If the PRD is ambiguous, list **questions for the user** separately.

## Task record shape

For each task, output:

- **ID** — T-001, T-002, …
- **Subject** — Short imperative title (like a task list item)
- **Description** — What to change or build, in plain language
- **Depends on** — Task IDs or "none"
- **Can parallelize with** — Task IDs that could run in parallel if staffing allows, or "none"
- **Likely touch areas** — e.g., `src/api/`, `frontend/components/`, or "unknown until discovery"
- **Acceptance criteria** — Bullet list; must be checkable
- **Verification** — Commands or steps (tests, lint, manual scenario). If unknown, say what to research to define verification

Optional: map to a session task list tool if the user uses one:

- **subject** — Same as Subject
- **description** — Same as Description plus dependencies in one line if helpful

## Output format

Produce this structure in order:

1. **Assumptions** — Stack, scope boundaries, anything you inferred
2. **Milestone summary** — 3–7 bullets describing phases from this breakdown
3. **Task list** — Full table or numbered list using the task record shape above
4. **Parallelization map** — Short note: which tasks are independent enough for parallel agents or PRs
5. **Questions for the user** — Numbered, only what blocks clarity
6. **Suggested first task** — One ID to start with and why

Do not write implementation code. Do not repeat the entire PRD back. Focus on decomposition, dependencies, acceptance criteria, and verification.

Now read the attached document and produce the breakdown.
```

---

## How this maps to concepts in this repo

| Idea in this prompt | Where it appears in Claude Code |
|---------------------|----------------------------------|
| Breaking work into independent, merge-friendly units | [`src/skills/bundled/batch.ts`](../src/skills/bundled/batch.ts) (decompose into self-contained units, per-directory slicing) |
| Structured tasks with subject and description | [`src/tools/TaskCreateTool/prompt.ts`](../src/tools/TaskCreateTool/prompt.ts) |
| Acceptance criteria and verification | Plan mode attachments in [`src/utils/messages.ts`](../src/utils/messages.ts) (final plan includes verification) |
| Spikes when scope is unclear | Same as plan workflow Phase 1 / Explore before committing to design |

You can tighten the prompt for **only** decomposition (no milestones) by deleting section "Milestone summary" from the instructions inside the fence, or require **JSON** output by appending: "Emit the task list as JSON array with keys id, subject, description, dependsOn, acceptanceCriteria, verification."

---

## Usage tips

1. **Attach the PRD** as a file or paste it under the prompt in the same message.
2. If the repo is large, add one line: "Assume the monorepo root is … and the feature lives under …"
3. For agent execution, add: "After the breakdown, mark which tasks are each suitable for a separate agent with no shared files."
