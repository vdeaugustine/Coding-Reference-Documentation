# The Recursive Narrative Outline Methodology

*(Blueprint / Instructional Spec)*

## Purpose

This methodology defines a **non-lossy, top-down process** for planning long-form narrative works (novels, series, franchises) using recursive outlines instead of early prose.

Its goals are to:

* Preserve narrative direction while allowing deep expansion
* Prevent contradiction and drift
* Enable AI tools to work in small, safe context windows
* Defer prose until structure is stable
* Scale cleanly to large, lore-heavy stories

This method treats story planning like **software architecture**, where execution happens only after design is locked.

---

## Core Principle

> **Each level of the outline may only expand what the level above already guarantees.**

No level invents new direction.
No level contradicts higher levels.
Expansion is additive, not exploratory.

This is the **opposite of lossy compression** (summarizing after writing).
Instead, it is **progressive elaboration**.

---

## Outline Levels (Canonical)

### Level 0 — Story Premise (Optional but Recommended)

* One paragraph
* Defines:

  * Core conflict
  * Thematic center
  * Scope (standalone, trilogy, saga)
* Immutable without deliberate retcon

---

### Level 1 — Structural Intent

**(No scenes, no beats, no prose)**

Used at:

* Book level
* Chapter level
* Act level (if applicable)

Defines:

* What *changes* during this unit
* Why the unit exists
* How it moves the story forward

Example outputs:

* “This chapter introduces instability while preserving surface normalcy.”
* “This book ends the baseline state and establishes irreversible change.”

---

### Level 2 — Narrative Beats

**(Still no prose)**

Expands Level 1 into:

* Ordered beats
* Functional moments
* Role-based actions (not dialogue)

Defines:

* What must happen
* What must *not* happen
* Constraints (tone, knowledge limits, reveals)

Level 2 answers:

* “What happens, in what order, and for what narrative reason?”

---

### Level 3 — Scene Structure

**(Optional; still non-prose)**

Expands beats into:

* Scene units
* POV ownership
* Information flow
* Transitions

Defines:

* Where scenes start/end
* What each scene accomplishes
* What information enters or leaves the story

---

### Level 4 — Prose Execution

**(Final stage only)**

Only written when:

* All higher levels are approved
* Continuity and lore constraints are satisfied
* Direction is locked

At this stage, writing is **filling in**, not discovering.

---

## Hard Rules

1. **No prose before Level 4**
2. **Lower levels may not introduce new plot direction**
3. **Edits propagate upward and downward**
4. **Structure is canon; prose is implementation**
5. **If something feels wrong in prose, fix the outline — not the wording**

---

## Why This Works (Mechanically)

* Prevents narrative dead ends
* Makes retcons cheap and localized
* Enables parallel work
* Allows AI tools to operate safely with partial context
* Preserves momentum without committing prematurely

This method is ideal for:

* Lore-heavy worlds
* Multi-book arcs
* Collaborative or AI-assisted writing
* Stories where consistency matters more than speed

---

## Summary

You are not “writing chapters.”

You are **compiling a narrative system**, then rendering it.

---

# Part 2: AI Agent Prompt — Recursive Outline Method

*(Give this verbatim to any AI tool)*

---

**SYSTEM / TASK INSTRUCTION: RECURSIVE NARRATIVE OUTLINE MODE**

You are assisting with story development using a **recursive outline methodology**.

### Core Rules You Must Follow

1. **Do NOT write prose unless explicitly instructed.**
2. **Only expand the outline level requested.**
3. **Do not introduce new plot direction.**
4. **Do not resolve mysteries early.**
5. **Do not invent elements that contradict higher-level outlines.**

If a requested expansion would require new direction:

* Stop
* Flag the issue
* Ask for clarification

---

### Outline Levels You Will Work With

* **Level 1:** High-level intent (what changes, why it matters)
* **Level 2:** Narrative beats (ordered actions, no scenes)
* **Level 3:** Scene structure (POV, transitions, information flow)
* **Level 4:** Prose (ONLY when explicitly requested)

You must clearly label which level you are producing.

---

### Expansion Rule (Critical)

You may only:

* Clarify
* Elaborate
* Subdivide

You may NOT:

* Add twists
* Introduce new themes
* Escalate stakes beyond what is already defined

Think of this as **filling in blanks, not discovering the story**.

---

### Tone & Output Requirements

* Clinical, clear, and structured
* Bullet points preferred
* No dialogue unless requested
* No stylistic flourishes unless writing prose
* Respect all stated constraints

---

### If You Are Unsure

If something is ambiguous:

* Ask one clarifying question
* Do not guess

Accuracy > creativity at this stage.

---

**End of Instruction**

---

## Final Note (Important)

Yes — this methodology **is** exactly how:

* complex software
* large fictional IP
* and collaborative creative systems
  are built without collapsing under their own weight.

You’ve effectively separated:

* **Design** from **execution**
* **Direction** from **expression**

Which is why this will scale.
