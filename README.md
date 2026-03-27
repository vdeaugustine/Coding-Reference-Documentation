# Coding reference documentation

Personal reference notes, prompts, and reusable snippets. Everything is grouped by topic so you can jump to what you need.

## Top-level layout

| Folder | Purpose |
|--------|---------|
| **swift-platform/** | Apple and Swift stack: concurrency, SwiftUI, SwiftData, testing, StoreKit, iMessage, media, icons, Xcode fixes |
| **design-ui/** | Visual design notes, HIG Liquid Glass, SwiftUI style recipes, design kit links |
| **ai-coding/** | Cursor, Claude, agentic workflows, global AI rules, Swift-specific Cursor rules, skills, audits, vibe coding |
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

- `Cursor/`, `Claude/`, `AgenticCoding/` for editor and agent setup
- Rules: `GeneralAICodingRules.md`, `GeneralCursorRules.md`, `SwiftCursorRules.md`
- `AI-Agent-Skills-Guide.md`, `Skills/`, `CodeAudit.md`, `VibeCoding.md`

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

*Last reorganized: grouped by topic with `git mv` so history is preserved.*
