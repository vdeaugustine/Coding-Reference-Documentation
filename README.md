# Coding reference documentation

Personal reference notes, prompts, and reusable snippets. Everything is grouped by topic so you can jump to what you need.

## Top-level layout

| Folder | Purpose |
|--------|---------|
| **swift-platform/** | Apple and Swift stack: concurrency, SwiftUI, SwiftData, testing, StoreKit, iMessage, media, icons, Xcode fixes |
| **design-ui/** | Visual design notes, HIG Liquid Glass, SwiftUI style recipes, design kit links |
| **ai-coding/** | Cursor, Claude, AgenticCoding (rules, workflows, guides), global AI rules, Swift Cursor rules, Codex-style **Skills** packs, audits, vibe coding |
| **prompts/** | Reusable prompts (GPT practices, JSON prompting, product building, checkpoints, context helpers) |
| **planning/** | Roadmaps and requirements writing |
| **reference/** | Long-form reference, storytelling, outlining, git and worktrees, workflow notes, Sora reference |
| **scripts/** | Shell helpers (`ExportCode.sh`, `git-cleanup.sh`) |

## Swift platform (`swift-platform/`)

- Concurrency: `SwiftConcurrency.md`, `Handling Swift Concurrency Warnings in Xcode.md`
- UI: `SwiftUI_Navigation.md`, `SwiftUISheetPresentationFix.md`
- Data and tests: `SwiftData.md`, `SwiftDataExtended.md`, `SwiftTesting.md`
- Features: `SwiftPhotoPickers.md`, `iMessageExtensions.md`
- Project norms: `SwiftProjects/ProjectGuidelines.md`
- Guides: `ios-app-icon-guide.md`, StoreKit and media `.txt` exports, `FixingXcodeCommands`

## Design and UI (`design-ui/`)

- `Design/` and `UI/` for tool-specific and component style notes
- `HIG_LiquidGlass.md`, `UI_DESIGN_LANGUAGE.md`, `DesignPreferences.txt`

## AI coding (`ai-coding/`)

- **Editors and agents:** `Cursor/`, `Claude/`, `AgenticCoding/` (guides, hooks, subagents)
- **Shared rules (markdown):** `GeneralAICodingRules.md`, `GeneralCursorRules.md`, `SwiftCursorRules.md`
- **AgenticCoding rules:** `AgenticCoding/rules/compile.md`, `AgenticCoding/rules/gather.md`
- **AgenticCoding workflows:** `AgenticCoding/workflows/`  
  `code-audit.md`, `compile-all.md`, `compile-apple.md`, `do-not-build.md`, `do-not-test.md`, `init-all.md`, `init-apple.md`, `ui-ux-designer.md`
- **Top-level references:** `AI-Agent-Skills-Guide.md`, `CodeAudit.md`, `VibeCoding.md`

### Skills (`ai-coding/Skills/`)

Reusable skill packages (each folder is typically `SKILL.md` plus agents, assets, scripts). Flat files at the root of `Skills/` are quick notes: `Debugging.md`, `PerfectionistCodeAuditor.md`.

| Theme | Skill folders |
|-------|----------------|
| Apple / Swift | `apple-progressive-disclosure`, `liquid-glass`, `swiftui-sheet-item-fixer`, `xcode-compile-fixer` |
| Agents / process | `autonomous-coding-orchestrator`, `subagent-workflow`, `character-profile`, `code-audit-agent-splitter` |
| Web / deploy | `compile`, `firebase-hosting-deployment`, `vercel-deploy`, `webapp-compile-run-check` |
| Git / CI | `git-commit`, `gh-fix-ci`, `merge-conflict-minimal-resolver` |
| Design / media | `ux-design-expert`, `remotion-video-skill-main` |

## Prompts (`prompts/`)

- Root-level prompt files plus `ProductBuilding/` for founder-oriented prompts

## Planning (`planning/`)

- `IdeaToReal_Roadmap.md`, `writing_requirements_doc.md`

## Reference (`reference/`)

- `ReferenceDocs/` (e.g. Sora), `Outlining/`, storytelling and workflow docs
- `git-reference.md`, `Worktrees.md`

## Scripts (`scripts/`)

- `ExportCode.sh`, `HelpfulScripts/git-cleanup.sh`

---

*Latest update reflected here: AgenticCoding **rules** (`compile`, `gather`), **workflows** (audit, compile, init, UI/UX, guardrails), and expanded **Skills** (folder-based packs with scripts and assets). Earlier top-level grouping used `git mv` so history is preserved.*
