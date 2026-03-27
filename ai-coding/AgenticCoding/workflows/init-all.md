---
description: Same thing as CLAUDE /init command; but it does it for all agents.
---

Please analyze this codebase and create an AGENTS.md file that will be provided to future AI coding agents working in this repository.

What to add:
1. Commands that will be commonly used (build, lint, test). Include the necessary commands to develop in this codebase, including how to run a single test (or an equivalent targeted test workflow).
2. High-level code architecture and structure so future agents can be productive quickly. Focus on the “big picture” architecture that requires reading multiple files to understand.

Usage notes:
- If there’s already an AGENTS.md (or similar: CLAUDE.md, AI.md, etc.), suggest improvements rather than duplicating content.
- In the initial AGENTS.md, do not repeat yourself and do not include obvious generic guidance (e.g., “provide helpful error messages”, “write unit tests for everything”, “never commit secrets”).
- Avoid listing every component or file structure that can be easily discovered by browsing the repo.
- Don’t include generic development practices.
- If there are agent/editor rules (e.g., .cursor/rules/, .cursorrules, .github/copilot-instructions.md, or similar), incorporate the important parts.
- If there is a README.md, incorporate the important parts.
- Do not invent sections like “Common Development Tasks”, “Tips”, or “Support” unless those topics are explicitly present in files you read.
- Prefix the file with:

## Saving this document (required)
1) Save this file as **`CLAUDE.md`** at the **root of the repository**.  
2) Copy it exactly (byte-for-byte) so all AI tools load the same instructions:

```bash
cp CLAUDE.md GEMINI.md
cp CLAUDE.md AGENTS.md
```

## If these files already exist
Then the user called this so that you will make sure they are up to date. So just analyze the existing files, then analyze the project, and make sure everything mentioned is accurate and up to date.