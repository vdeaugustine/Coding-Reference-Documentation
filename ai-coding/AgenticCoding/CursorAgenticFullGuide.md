**The Complete Guide to AI Agent Skills in Cursor**

**Executive Summary**

Agent Skills is an open standard for extending AI agents with specialized capabilities, domain-specific knowledge, and custom workflows. Originally developed by Anthropic for Claude Code, Agent Skills has become a universal format adopted across multiple AI coding tools including Cursor, GitHub Copilot, and other AI-powered editors.

Skills package reusable instructions, commands, and automation scripts that agents can discover and invoke when relevant. Unlike rules that apply to every conversation, skills are loaded dynamically on demand, keeping your context window clean while giving agents access to powerful specialized capabilities.

This guide provides complete documentation on creating, configuring, and using Agent Skills in Cursor, including file structure, syntax, examples, and best practices.

**What Are Agent Skills?**

**Core Concept**

Agent Skills extend what AI agents can do by packaging domain-specific knowledge, workflows, and scripts into reusable modules. Each skill is defined in a SKILL.md file that tells the agent:

1. When to use the skill (activation criteria)

2. What the skill does (instructions and workflows)

3. How to invoke it (custom commands)

4. What scripts to run (hooks for automation)

**Skills vs Rules**

Understanding the difference between Skills and Rules is essential for effective agent customization:

| Aspect         | Rules                                       | Skills                                        |
| :------------- | :------------------------------------------ | :-------------------------------------------- |
| Loading        | Always included in every conversation       | Loaded dynamically when relevant              |
| File Location  | .cursor/rules/                              | .cursor/skills/                               |
| Best For       | Static context, code style, commands to run | Domain expertise, workflows, procedures       |
| Context Impact | Always consumes context window              | Only loaded when needed                       |
| Use Case       | Project conventions, patterns, linting      | Git workflows, testing procedures, deployment |

Table 1: Comparison of Rules and Skills in Cursor

**Rules** provide persistent instructions that shape how the agent works with your code. Think of them as always-on context that the agent sees at the start of every conversation. Use rules for essential information like commands to run, patterns to follow, and pointers to canonical examples in your codebase\[5\].

**Skills** are loaded dynamically when the agent decides they're relevant. This keeps your context window clean while giving the agent access to specialized capabilities. Use skills for procedural "how-to" instructions, complex workflows, and domain-specific knowledge that only applies to certain tasks\[5\].

**How Skills Work**

When you submit a prompt to the agent, Cursor:

1. Scans all installed skills by reading their metadata

2. Checks the "when to use" criteria against your request

3. Loads relevant skills into the agent's context

4. Executes the skill's instructions when invoked

5. Returns to standard behavior after completion

Skills can also be invoked explicitly using the slash command menu by typing / followed by the skill name in the agent input\[11\].

**System Requirements**

**Prerequisites**

Agent Skills are currently only available in the **Nightly release channel** of Cursor. To enable skills\[5\]:

1. Open Cursor settings

2. Select the **Beta** menu

3. Set your update channel to **Nightly**

4. Restart Cursor

**Enabling/Disabling Skills**

To enable or disable Agent Skills\[14\]:

1. Open Cursor Settings

2. Navigate to Rules

3. Find the Import Settings section

4. Toggle Agent Skills on or off

**File Structure and Organization**

**Directory Structure**

Skills are organized in dedicated directories within your project or user configuration:

**Project-level skills** (apply to specific project):  
project-root/  
.cursor/  
skills/  
skill-name/  
[SKILL.md](http://SKILL.md)  
another-skill/  
[SKILL.md](http://SKILL.md)

**User-level skills** (apply globally across all projects):  
\~/.cursor/skills/  
skill-name/  
[SKILL.md](http://SKILL.md)  
another-skill/  
[SKILL.md](http://SKILL.md)

Each skill resides in its own subdirectory containing at minimum a SKILL.md file. Additional files like scripts, configuration, or resources can be included in the skill directory.

**Naming Conventions**

1. **Skill directory names**: Use lowercase with hyphens (kebab-case): code-review, git-workflow, test-runner

2. [**SKILL.md**](http://SKILL.md) **filename**: Must be exactly SKILL.md (all caps)

3. **Skill identifiers**: Should be descriptive and unique: frontend-design, api-documentation, security-audit

[**SKILL.md**](http://SKILL.md) **Format Specification**

**File Structure**

The SKILL.md file uses a combination of YAML frontmatter and Markdown content:

---

**YAML frontmatter (metadata and configuration)**

**name: my-skill**  
**version: 1.0.0**  
**description: A brief description**  
**when_to_use: When the user asks to perform specific task**

**Markdown content (system prompt and instructions)**

Your detailed instructions, workflows, and documentation go here.  
The agent follows these instructions when the skill is invoked.

The file has two distinct parts:

1. **YAML Frontmatter** (between \--- markers): Metadata that tells Claude when to use the skill, what permissions it needs, and how it behaves

2. **Markdown Content** (after frontmatter): Detailed instructions, workflows, examples, and documentation that guide the agent's behavior when the skill is active

**Required Fields**

Every [SKILL.md](http://SKILL.md) must include these core fields:

---

**name: unique-skill-identifier**  
**version: 1.0.0**  
**description: Brief description of what this skill does (max 160 characters)**  
**when_to_use: Clear criteria for when the agent should invoke this skill**

**Field descriptions**:

1. **name**: Unique identifier for the skill (lowercase with hyphens)

2. **version**: Semantic version number (MAJOR.MINOR.PATCH format)

3. **description**: Concise explanation of the skill's purpose (optimized for SEO and discovery)

4. **when_to_use**: Natural language criteria that helps the agent decide when to load this skill

**Optional Metadata Fields**

**Categorization**

category: development \# Primary category  
subcategory: code-quality \# More specific classification  
type: command \# Skill type: command, agent, hook, or mcp  
difficulty: intermediate \# beginner, intermediate, or advanced  
audience:

- developers

- tech-leads

- security-engineers

**Author and Licensing**

author: Your Name  
email: [you@example.com](mailto:you@example.com)  
license: MIT  
repository: [https://github.com/username/skill-repo](https://github.com/username/skill-repo)  
homepage: [https://yoursite.com](https://yoursite.com)  
keywords:

- code-review

- security

- automation

**Dependencies**

dependencies:  
tools:  
\- git  
\- npm  
\- eslint  
skills:  
\- base-skill  
\- helper-skill  
npm:  
\- eslint: "^8.0.0"  
\- prettier: "^2.8.0"

**Input Configuration**

Define what arguments and context the skill accepts:

input:  
arguments:  
\- name: files  
type: string\[\]  
description: Files to process  
required: true  
\- name: strict  
type: boolean  
description: Enable strict mode  
required: false  
default: false  
\- name: format  
type: string  
description: Output format  
required: false  
default: "markdown"  
enum: \["markdown", "json", "html"\]

context:  
requiresProject: true  
requiresGit: false  
requiresPackageJson: false

**Supported argument types**: string, number, boolean, string\[\], object

**Output Configuration**

Specify the skill's output format and structure:

output:  
format: markdown \# text, markdown, json, or code

**For JSON output, define the schema**

schema:  
type: object  
properties:  
issues:  
type: array  
items:  
type: object  
properties:  
severity:  
type: string  
enum: \[critical, high, medium, low\]  
file:  
type: string  
line:  
type: number  
message:  
type: string

**Behavior Configuration**

Control execution characteristics:

behavior:  
timeout: 120 \# Maximum execution time in seconds

retry:  
maxAttempts: 3  
backoffMs: 1000

cache:  
enabled: true  
ttlSeconds: 3600  
keyFields:  
\- files  
\- strict

**Permissions and Security**

Define what operations the skill can perform:

permissions:  
filesystem:  
read: true  
write: false  
paths:  
allowed:  
\- "src/  
**"- "tests/**"  
denied:  
\- "node_modules/\*\*"  
\- ".env"

network:  
enabled: false  
domains:  
allowed:  
\- "[api.example.com](http://api.example.com)"  
denied:  
\- "\*"

tools:  
allowed:  
\- read_file  
\- grep  
\- glob  
\- bash

bashCommands:  
allowed:  
\- "npm list"  
\- "git log"  
\- "git diff"  
denied:  
\- "rm \-rf"  
\- "sudo \*"

**Complete Example**

Here's a comprehensive example showing all major fields:

---

name: code-review  
version: 1.2.0  
description: Automated code review with security and performance analysis  
author: Your Team  
license: MIT  
category: development  
subcategory: code-quality  
type: command  
difficulty: intermediate  
audience:

- developers

- tech-leads

when_to_use: |  
When the user asks to review code, check for issues, or analyze code quality.  
Also relevant when preparing for pull requests or code audits.

input:  
arguments:  
\- name: files  
type: string\[\]  
description: Files or directories to review  
required: false  
default: \["."\]  
\- name: focus  
type: string  
description: Focus area for review  
required: false  
enum: \["security", "performance", "style", "all"\]  
default: "all"

output:  
format: markdown

behavior:  
timeout: 180  
cache:  
enabled: true  
ttlSeconds: 1800

**permissions:**  
**filesystem:**  
**read: true**  
**write: false**  
**tools:**  
**allowed:**  
**\- read_file**  
**\- grep**  
**\- glob**

**Code Review Instructions**

When reviewing code, follow this systematic approach:

**1\. Security Analysis**

Look for:

- Hardcoded credentials or API keys

- SQL injection vulnerabilities

- XSS vulnerabilities in user input handling

- Insecure dependencies

**2\. Performance Review**

Check for:

- Inefficient loops or algorithms

- Memory leaks

- Unnecessary re-renders in React

- Missing database indexes

**3\. Code Quality**

Evaluate:

- Code organization and structure

- Naming conventions

- Comments and documentation

- Error handling

- Test coverage

**Output Format**

Present findings in this structure:

**Critical Issues**

- \[List any critical security or breaking issues\]

**High Priority**

- \[List important performance or correctness issues\]

**Suggestions**

- \[List style improvements and optimizations\]

**Positive Observations**

- \[Highlight well-written code\]

**Creating Custom Skills**

**Basic Skill Creation**

To create a new skill:

1. Create the skill directory:  
   mkdir \-p .cursor/skills/my-skill

2. Create [SKILL.md](http://SKILL.md) file:  
   touch .cursor/skills/my-skill/SKILL.md

3. Define the skill using the format shown above

4. Save the file and restart the agent conversation

**Skill Types**

**Command Skills**

Command skills are invoked explicitly with /command-name:

---

**name: create-component**  
**version: 1.0.0**  
**description: Generate a new React component with tests**  
**type: command**  
**when_to_use: When user asks to create a new component**

**Component Creation Workflow**

1. Ask for the component name

2. Create the component file in src/components/

3. Generate a test file in src/components/**tests**/

4. Add the component to the index export

Use this file structure:  
// Component template  
import React from 'react';

export const ComponentName \= () \=\> {  
return

ComponentName

;  
};

Invoke with: /create-component

**Agent Skills**

Agent skills provide ongoing expertise that the agent can reference:

---

**name: frontend-design**  
**version: 1.0.0**  
**description: Best practices for frontend UI/UX implementation**  
**type: agent**  
**when_to_use: When building or modifying user interfaces**

**Frontend Design Guidelines**

**Layout Principles**

- Use flexbox or grid for responsive layouts

- Mobile-first approach

- Consistent spacing using 8px baseline

**Accessibility**

- Semantic HTML elements

- ARIA labels where needed

- Keyboard navigation support

- Color contrast ratios (WCAG AA minimum)

**Performance**

- Lazy load images

- Code splitting for large components

- Minimize bundle size

**Hook Skills**

Hook skills execute scripts at specific lifecycle points. More details in the Hooks section below.

**MCP Skills**

MCP (Model Context Protocol) skills integrate external services:

---

**name: github-integration**  
**version: 1.0.0**  
**description: GitHub API integration for issue and PR management**  
**type: mcp**  
**when_to_use: When working with GitHub issues or pull requests**

**GitHub Integration**

This skill connects to GitHub's API to:

- Create and update issues

- Manage pull requests

- Search repositories

- Check CI status

Available actions:

- /create-issue \- Create new GitHub issue

- /update-pr \- Update pull request details

- /check-ci \- Check CI/CD status

**Markdown Content Best Practices**

The markdown section after the frontmatter is where you provide detailed instructions. Follow these guidelines:

1. **Be specific**: Provide exact patterns, file structures, and examples

2. **Use headings**: Organize instructions with clear section headers

3. **Include examples**: Show code samples and expected outputs

4. **Reference files**: Point to canonical examples in your codebase

5. **Define workflows**: Use numbered lists for step-by-step procedures

6. **Add context**: Explain why certain approaches are preferred

7. **Keep it focused**: Each skill should have a single, clear purpose

**Version Management**

Follow semantic versioning (MAJOR.MINOR.PATCH):

**Breaking change (incompatible API changes)**

version: 2.0.0

**New feature (backwards-compatible functionality)**

version: 1.1.0

**Bug fix (backwards-compatible bug fixes)**

version: 1.0.1

Version your skills thoughtfully to maintain compatibility and communicate changes to users.

**Using Skills in Cursor**

**Automatic Discovery**

The agent automatically discovers and loads relevant skills based on your prompts. When you describe a task, the agent:

1. Analyzes your request

2. Checks the when_to_use criteria across all installed skills

3. Loads matching skills into its context

4. Applies the skill's instructions to your task

Example: If you ask "Create a landing page for my startup", the agent might automatically load skills like frontend-design, responsive-layout, and seo-optimization based on their activation criteria.

**Manual Invocation with Slash Commands**

You can explicitly invoke any skill using the slash command menu:

1. In the agent input, type /

2. Browse available skills or start typing the skill name

3. Select the skill from the dropdown

4. The agent loads and executes that skill

Example commands:  
/code-review  
/create-component Button  
/git-workflow feature-branch  
/deploy production

**Checking Available Skills**

To see what skills are available, ask the agent:

What skills do you have?

or

List all available skills

The agent will display skills from both Cursor's built-in skills and any custom skills you've added to your project or user directory\[9\].

**Hooks System**

**Overview**

Hooks are scripts that run at specific trigger points during the agent's lifecycle. They enable powerful automation patterns like running tests after code changes, formatting files before commits, or implementing custom agent loops\[5\].

**Hook Types**

Cursor supports five hook types:

| Hook Type        | When It Runs                                                |
| :--------------- | :---------------------------------------------------------- |
| agentSpawn       | When the agent is first activated                           |
| userPromptSubmit | When the user submits a prompt                              |
| preToolUse       | Before the agent uses a specific tool (can block execution) |
| postToolUse      | After the agent uses a specific tool                        |
| stop             | When the agent finishes responding (task completion)        |

Table 2: Agent hook types and their trigger points

**Configuration File**

Hooks are configured in .cursor/hooks.json:

{  
"version": 1,  
"hooks": {  
"agentSpawn": \[  
{ "command": "git status" }  
\],  
"userPromptSubmit": \[  
{ "command": "ls \-la" }  
\],  
"preToolUse": \[  
{  
"matcher": "execute_bash",  
"command": "echo 'Running bash command' \>\> audit.log"  
}  
\],  
"postToolUse": \[  
{  
"matcher": "fs_write",  
"command": "npm run format"  
}  
\],  
"stop": \[  
{ "command": "npm test" }  
\]  
}  
}

**Hook Input and Output**

**Input Format**

Hooks receive JSON input via stdin. The format varies by hook type:

**For stop hooks**:  
{  
"conversation_id": "abc123",  
"status": "completed",  
"loop_count": 1  
}

Status values:

- completed: Agent finished successfully

- aborted: User interrupted the agent

- error: Agent encountered an error

**Output Format**

Hooks can return JSON to control agent behavior:

{  
"followup_message": "Continue working on the task"  
}

An empty object or no output means the agent should stop:  
{}

**Long-Running Agent Loop Example**

One powerful pattern is using the stop hook to create agents that iterate until they achieve a goal:

**.cursor/hooks.json**:  
{  
"version": 1,  
"hooks": {  
"stop": \[  
{ "command": "bun run .cursor/hooks/grind.ts" }  
\]  
}  
}

**.cursor/hooks/grind.ts**:  
import { readFileSync, existsSync } from "fs";

interface StopHookInput {  
conversation_id: string;  
status: "completed" | "aborted" | "error";  
loop_count: number;  
}

const input: StopHookInput \= await Bun.stdin.json();  
const MAX_ITERATIONS \= 5;

// Stop if aborted, errored, or hit max iterations  
if (input.status \!== "completed" || input.loop_count \>= MAX_ITERATIONS) {  
console.log(JSON.stringify({}));  
process.exit(0);  
}

// Check if agent marked task as done  
const scratchpad \= existsSync(".cursor/scratchpad.md")  
? readFileSync(".cursor/scratchpad.md", "utf-8")  
: "";

if (scratchpad.includes("DONE")) {  
console.log(JSON.stringify({}));  
} else {  
console.log(JSON.stringify({  
followup_message: \[Iteration ${input.loop\_count \+ 1}/${MAX_ITERATIONS}\] Continue working. Update .cursor/scratchpad.md with DONE when complete.  
}));  
}

This pattern works well for:

- Running and fixing tests until all pass

- Iterating on UI until it matches a design

- Any goal-oriented task where success is verifiable

**Tool Matchers**

For preToolUse and postToolUse hooks, use the matcher field to target specific tools:

{  
"hooks": {  
"preToolUse": \[  
{  
"matcher": "fs_write",  
"command": "echo 'About to write file' \>\> log.txt"  
}  
\],  
"postToolUse": \[  
{  
"matcher": "execute_bash",  
"command": "echo 'Bash command completed' \>\> log.txt"  
}  
\]  
}  
}

Common tool names:

- fs_read: File reading operations

- fs_write: File writing operations

- execute_bash: Shell command execution

- grep: Code search operations

- glob: File pattern matching

Matchers support wildcards:  
{  
"matcher": "fs\_\*" // Matches fs_read, fs_write, etc.  
}

**Hook Use Cases**

1. **Automated testing**: Run tests after code changes

2. **Code formatting**: Format files after writes

3. **Audit logging**: Track all file modifications

4. **Security scanning**: Check for vulnerabilities before commits

5. **Build verification**: Ensure code compiles after changes

6. **Git automation**: Auto-commit with meaningful messages

7. **Deployment**: Trigger deployments after successful builds

**Practical Examples**

**Example 1: Git Workflow Skill**

Create a skill that automates pull request creation:

**.cursor/skills/create-pr/SKILL.md:**

**name: create-pr**  
**version: 1.0.0**  
**description: Create a pull request with generated title and description**  
**type: command**  
**when_to_use: When user wants to create a pull request for current changes**

**Pull Request Creation Workflow**

Follow these steps to create a well-formed pull request:

**1\. Check Status**

Run git status to see what's changed

**2\. Generate Commit Message**

Look at git diff to understand changes and write a clear commit message:

- Use conventional commit format: type(scope): description

- Types: feat, fix, docs, style, refactor, test, chore

- Keep first line under 50 characters

- Add detailed body if needed

**3\. Commit and Push**

git add .  
git commit \-m "Your message"  
git push origin HEAD

**4\. Create PR**

Use GitHub CLI to create the pull request:  
gh pr create \--title "Title" \--body "Description"

Include in the description:

- What changed and why

- How to test

- Any breaking changes

- Screenshots for UI changes

**5\. Return PR URL**

Provide the user with the created PR URL

Usage: Type /create-pr in the agent input and the agent will execute this workflow.

**Example 2: Frontend Design Skill**

A skill that ensures consistent UI implementation:

**.cursor/skills/frontend-design/SKILL.md:**

**name: frontend-design**  
**version: 1.0.0**  
**description: Frontend development best practices and UI patterns**  
**type: agent**  
**when_to_use: When building or modifying user interfaces, creating components, or implementing designs**

**Frontend Design System**

Apply these principles when building user interfaces:

**Component Structure**

Use this canonical structure for React components:

import React from 'react';  
import styles from './Component.module.css';

interface ComponentProps {  
// Define props with TypeScript  
title: string;  
onAction?: () \=\> void;  
}

export const Component: React.FC\<ComponentProps\> \= ({  
title,  
onAction  
}) \=\> {  
return (

**{title}**

{onAction && (  
Action  
)}

);  
};

**Layout System**

- Use CSS Grid for page layouts

- Use Flexbox for component internals

- Mobile-first responsive design

- Breakpoints: 640px (sm), 768px (md), 1024px (lg), 1280px (xl)

**Spacing Scale**

Use consistent spacing based on 4px units:

- xs: 4px

- sm: 8px

- md: 16px

- lg: 24px

- xl: 32px

- 2xl: 48px

**Color Usage**

- Primary: Brand colors for main actions

- Secondary: Supporting elements

- Neutral: Text and backgrounds

- Semantic: Success (green), warning (yellow), error (red), info (blue)

**Accessibility Requirements**

1. Semantic HTML (header, nav, main, section, article, footer)

2. Alt text for all images

3. ARIA labels for icon buttons

4. Keyboard navigation (tab order, focus states)

5. Color contrast minimum 4.5:1 for text

6. Focus indicators visible and clear

**Performance**

- Lazy load images with loading="lazy"

- Code split large components with React.lazy()

- Memoize expensive computations with useMemo

- Debounce search inputs and expensive callbacks

- Optimize images (WebP format, appropriate sizes)

**Testing**

Create tests alongside components:  
// Component.test.tsx  
import { render, screen } from '@testing-library/react';  
import { Component } from './Component';

describe('Component', () \=\> {  
it('renders title', () \=\> {  
render();  
expect(screen.getByText('Test')).toBeInTheDocument();  
});  
});

**Example 3: Test-Driven Development Skill**

A skill for TDD workflows:

**.cursor/skills/tdd-workflow/SKILL.md:**

**name: tdd-workflow**  
**version: 1.0.0**  
**description: Test-driven development workflow automation**  
**type: command**  
**when_to_use: When user wants to follow TDD practices or write tests first**

**Test-Driven Development Workflow**

Follow the red-green-refactor cycle:

**Phase 1: Red (Write Failing Test)**

1. **Understand requirements**: Clarify what functionality is needed

2. **Write the test first**: Create a test that defines the expected behavior

3. **Run the test**: Confirm it fails (red) because implementation doesn't exist yet

4. **Do NOT write implementation yet**: Resist the urge to fix it

Example test structure:  
describe('calculateTotal', () \=\> {  
it('should sum array of numbers', () \=\> {  
const input \= \[1, 2, 3, 4\];  
const result \= calculateTotal(input);  
expect(result).toBe(10);  
});

it('should handle empty array', () \=\> {  
expect(calculateTotal(\[\])).toBe(0);  
});

it('should handle negative numbers', () \=\> {  
expect(calculateTotal(\[-1, \-2, 3\])).toBe(0);  
});  
});

**Phase 2: Green (Make It Pass)**

1. **Write minimal code**: Implement just enough to make the test pass

2. **Run tests**: Verify they pass (green)

3. **No optimization yet**: Focus on correctness, not elegance

**Phase 3: Refactor (Improve Code)**

1. **Improve the code**: Clean up, optimize, remove duplication

2. **Run tests after each change**: Ensure nothing breaks

3. **Commit when satisfied**: Save your work

**Best Practices**

- Write one test at a time

- Keep tests independent and isolated

- Use descriptive test names that explain behavior

- Test edge cases and error conditions

- Mock external dependencies

- Run full test suite before committing

**Commands**

- Run tests: npm test

- Run specific test: npm test \-- ComponentName.test.ts

- Watch mode: npm test \-- \--watch

- Coverage report: npm test \-- \--coverage

**Example 4: Code Review Skill**

A comprehensive code review skill:

**.cursor/skills/code-review/SKILL.md:**

**name: code-review**  
**version: 1.2.0**  
**description: Systematic code review covering security, performance, and quality**  
**type: command**  
**when_to_use: When user asks to review code, check for issues, or prepare for PR**

**Code Review Guidelines**

Perform a thorough review covering these areas:

**1\. Security Analysis**

**Critical Security Issues**

Look for:

**Hardcoded Secrets**:  
// ❌ Bad  
const apiKey \= "sk_live_abc123";  
const password \= "admin123";

// ✅ Good  
const apiKey \= process.env.API_KEY;

**SQL Injection**:  
// ❌ Bad  
const query \= SELECT \* FROM users WHERE id \= ${userId};

// ✅ Good  
const query \= SELECT \* FROM users WHERE id \= ?;  
db.query(query, \[userId\]);

**XSS Vulnerabilities**:  
// ❌ Bad  
element.innerHTML \= userInput;

// ✅ Good  
element.textContent \= userInput;

**Authentication Issues**:

- Missing authentication checks

- Weak password requirements

- Insecure session management

- Missing rate limiting

**2\. Performance Review**

**Common Performance Issues**

**Inefficient Loops**:  
// ❌ Bad: O(n²)  
for (let i \= 0; i \< arr.length; i++) {  
for (let j \= 0; j \< arr.length; j++) {  
// nested operation  
}  
}

// ✅ Good: O(n) with Map  
const map \= new Map(arr.map(item \=\> \[[item.id](http://item.id), item\]));

**Memory Leaks**:

- Event listeners not removed

- Timers not cleared

- Large data structures not released

**React Performance**:

- Missing key props in lists

- Unnecessary re-renders

- Missing useMemo/useCallback for expensive operations

**Database Performance**:

- N+1 query problems

- Missing indexes

- Fetching unnecessary columns

**3\. Code Quality**

**Structure and Organization**

- **Single Responsibility**: Each function/class does one thing

- **DRY**: Don't Repeat Yourself \- extract common logic

- **Naming**: Clear, descriptive names that explain purpose

- **Function Length**: Keep functions under 50 lines

- **File Length**: Keep files under 300 lines

**Error Handling**

// ❌ Bad: Silent failure  
try {  
await fetchData();  
} catch (e) {  
// Nothing  
}

// ✅ Good: Proper error handling  
try {  
const data \= await fetchData();  
return data;  
} catch (error) {  
logger.error('Failed to fetch data', { error });  
throw new DataFetchError('Unable to load data', { cause: error });  
}

**Type Safety**

// ❌ Bad: any types  
function process(data: any): any {  
return data.value;  
}

// ✅ Good: Specific types  
interface DataType {  
value: string;  
metadata: Record\<string, unknown\>;  
}

function process(data: DataType): string {  
return data.value;  
}

**4\. Testing**

**Test Coverage Expectations**

- Critical paths: 100% coverage

- Business logic: 90%+ coverage

- UI components: 80%+ coverage

- Utilities: 100% coverage

**Test Quality**

- Tests are independent

- Tests are deterministic (no flaky tests)

- Tests have clear arrange-act-assert structure

- Edge cases are covered

- Error conditions are tested

**5\. Documentation**

Check for:

- README with setup instructions

- API documentation for public functions

- Complex logic explained with comments

- Architecture decisions documented

- Breaking changes noted

**Output Format**

Structure your review as:

**🔴 Critical Issues**

\[Security vulnerabilities, breaking bugs, data loss risks\]

**🟡 High Priority**

\[Performance issues, code quality problems, missing tests\]

**🟢 Suggestions**

\[Style improvements, optimizations, refactoring opportunities\]

**✅ Positive Observations**

\[Well-written code, good patterns, excellent tests\]

**📊 Metrics**

- Files changed: X

- Lines added/removed: \+X / \-Y

- Test coverage: Z%

- Complexity score: N

**Best Practices**

**Do's and Don'ts**

**✅ Do:**

1. Keep skills focused on a single domain or workflow

2. Use clear, descriptive names for skills

3. Include concrete examples and code samples

4. Reference canonical files in your codebase

5. Test skills thoroughly before committing

6. Version skills semantically

7. Document all parameters and expected behaviors

8. Keep when_to_use criteria specific and clear

9. Use permissions to limit what skills can do

10. Check skills into version control

**❌ Don't:**

1. Create overly broad skills that try to do everything

2. Use vague activation criteria

3. Include sensitive information in skills

4. Grant unnecessary permissions

5. Duplicate content from rules

6. Make skills dependent on external services without fallbacks

7. Forget to handle error cases

8. Leave placeholders or TODOs in production skills

**Performance Optimization**

1. **Keep skills small**: Large skills consume more context window

2. **Use specific activation criteria**: Prevent unnecessary loading

3. **Cache when possible**: Enable caching for deterministic operations

4. **Set appropriate timeouts**: Prevent skills from hanging

5. **Limit filesystem access**: Only read/write what's necessary

**Security Considerations**

1. **Principle of least privilege**: Grant minimum necessary permissions

2. **Validate inputs**: Check arguments before processing

3. **Sanitize outputs**: Clean data before returning to user

4. **Audit sensitive operations**: Log file writes, network calls, command execution

5. **Avoid secrets in skills**: Use environment variables or secure vaults

6. **Review bash commands**: Restrict dangerous operations (rm \-rf, sudo, etc.)

**Testing Skills**

Before deploying a skill:

1. **Test activation**: Verify when_to_use criteria work correctly

2. **Test execution**: Run the skill with various inputs

3. **Test edge cases**: Try invalid inputs, missing dependencies

4. **Test permissions**: Ensure security constraints are enforced

5. **Test with different models**: Skills may behave differently across models

6. **Test in isolation**: Disable other skills to verify independence

**Skill Maintenance**

1. **Review regularly**: Update skills as your codebase evolves

2. **Monitor usage**: Track which skills are actually used

3. **Gather feedback**: Ask team members about skill effectiveness

4. **Update versions**: Increment version numbers when making changes

5. **Deprecate carefully**: Provide migration paths for breaking changes

6. **Keep documentation current**: Update README and examples

**Advanced Patterns**

**Skill Chaining**

Skills can reference and build on each other:

---

**name: full-feature-workflow**  
**version: 1.0.0**  
**description: Complete workflow from planning to deployment**  
**when_to_use: When building a new feature from scratch**  
**dependencies:**  
**skills:**  
**\- git-workflow**  
**\- tdd-workflow**  
**\- code-review**

**Full Feature Development Workflow**

This skill chains multiple specialized skills:

1. **Planning**: Use /plan-feature to create architecture document

2. **Branch**: Use /git-workflow to create feature branch

3. **Development**: Use /tdd-workflow to build with tests

4. **Review**: Use /code-review to check quality

5. **Deploy**: Use /deploy-feature to ship to production

Each step invokes a specialized skill, creating a complete workflow.

**Conditional Skill Loading**

Skills can include logic for conditional execution:

**Conditional Execution**

**If project uses TypeScript:**

- Run type checking with npm run typecheck

- Generate type definitions

- Check for any types

**If project uses React:**

- Check for missing keys in lists

- Verify hooks rules compliance

- Look for performance anti-patterns

**If project uses testing library:**

- Verify test coverage meets threshold

- Check for proper cleanup in tests

**Context-Aware Skills**

Skills can adapt behavior based on project context:

---

**name: smart-deploy**  
**version: 1.0.0**  
**description: Context-aware deployment that adapts to project type**  
**when_to_use: When deploying to production or staging**

**Intelligent Deployment**

**Detect Project Type**

Check package.json and project structure to determine:

- Next.js app → Deploy to Vercel

- React app → Deploy to Netlify or S3

- Node.js API → Deploy to Railway or [Fly.io](http://Fly.io)

- Static site → Deploy to Cloudflare Pages

**Pre-deployment Checks**

1. Run tests: npm test

2. Build project: npm run build

3. Check bundle size

4. Verify environment variables

5. Run security audit: npm audit

**Deployment**

Execute platform-specific deployment commands based on detected type.

**Post-deployment**

1. Verify deployment URL responds

2. Run smoke tests

3. Check monitoring/logs

4. Notify team in Slack

**Integration with External Tools**

Skills can integrate with external services via MCP:

---

**name: github-automation**  
**version: 1.0.0**  
**description: Automate GitHub workflows with issues, PRs, and CI**  
**type: mcp**  
**when_to_use: When working with GitHub repositories**

**GitHub Automation**

**Available Operations**

**Issue Management**

- Create issues from code TODOs

- Label issues based on content

- Assign issues to team members

- Link related issues

**Pull Request Automation**

- Auto-generate PR descriptions from commits

- Request reviewers based on CODEOWNERS

- Add labels based on changed files

- Check CI status before merge

**Repository Management**

- Update repository settings

- Manage branch protection rules

- Configure webhooks

- Update documentation

**Example: Auto PR Description**

When creating a PR, analyze commits and generate:

**Changes**

\[Summary of changes from commits\]

**Testing**

\[Extracted from commit messages\]

**Breaking Changes**

\[Detected from conventional commits\]

**Related Issues**

\[Linked from commit messages\]

**Troubleshooting**

**Common Issues**

**Skill Not Loading**

**Problem**: Agent doesn't seem to use your skill

**Solutions**:

1. Verify file is named exactly [SKILL.md](http://SKILL.md) (case-sensitive)

2. Check YAML frontmatter syntax (no tabs, proper indentation)

3. Ensure when_to_use criteria are clear and specific

4. Restart agent conversation to reload skills

5. Check Cursor settings: Rules → Import Settings → Agent Skills is enabled

**Hook Not Executing**

**Problem**: Hook script doesn't run when expected

**Solutions**:

1. Verify hooks.json syntax is valid

2. Check that command path is correct and executable

3. Add logging to hook script to debug

4. Verify hook type matches intended trigger point

5. Check file permissions on hook scripts

**Permission Denied Errors**

**Problem**: Skill fails due to insufficient permissions

**Solutions**:

1. Review permissions section in [SKILL.md](http://SKILL.md)

2. Add required filesystem paths to allowed list

3. Enable necessary tool permissions

4. Check bash command restrictions

5. Verify network access if calling external APIs

**Skills Conflicting**

**Problem**: Multiple skills interfere with each other

**Solutions**:

1. Make when_to_use criteria more specific

2. Review skill scopes to ensure they're distinct

3. Temporarily disable skills to isolate issues

4. Check for overlapping permissions or hooks

5. Use skill chaining instead of independent parallel skills

**Debugging Techniques**

**Enable Verbose Logging**

Add debug output to your skills:

Before executing main workflow:

1. Echo current directory: pwd

2. List relevant files: ls \-la

3. Show git status: git status

4. Display environment: env | grep NODE

**Test Skills Independently**

Create a minimal test case:

1. Disable all other skills

2. Create new agent conversation

3. Invoke skill explicitly with /skill-name

4. Check behavior matches expectations

**Validate YAML Syntax**

Use an online YAML validator or command-line tool:

**Install yamllint**

npm install \-g yaml-lint

**Validate your [SKILL.md](http://SKILL.md) frontmatter**

yaml-lint .cursor/skills/\*/SKILL.md

**Check Agent Context**

Ask the agent what it knows:

What skills are currently loaded?  
What's in your current context?  
Show me the instructions from the \[skill-name\] skill

**Skill Marketplace and Resources**

**Official Resources**

1. **Cursor Documentation**: [https://cursor.com/docs/context/skills](https://cursor.com/docs/context/skills)

2. **Agent Best Practices**: [https://cursor.com/blog/agent-best-practices](https://cursor.com/blog/agent-best-practices)

3. **Cursor Community Forum**: [https://forum.cursor.com](https://forum.cursor.com)

4. **GitHub Discussions**: Search for "cursor skills" repositories

**Community Skill Repositories**

Many developers share skills publicly:

1. Search GitHub for "cursor-skills" or "agent-skills"

2. Check AI coding communities on Discord and Reddit

3. Follow Cursor's official releases for built-in skills

4. Join the Cursor community to share and discover skills

**Installing Community Skills**

To install a skill from a repository:

1. Clone or download the skill directory

2. Copy to .cursor/skills/ in your project or user directory

3. Review [SKILL.md](http://SKILL.md) for any setup requirements

4. Check permissions and security implications

5. Test the skill in a safe environment first

6. Customize for your specific needs

**Contributing Skills**

To share your skills with the community:

1. Create a public repository

2. Include comprehensive README with installation instructions

3. Provide examples and use cases

4. Document any dependencies or requirements

5. Add a license (MIT recommended for maximum compatibility)

6. Tag with relevant keywords: cursor-skills, agent-skills, ai-coding

7. Share on community forums and social media

**Future Developments**

Agent Skills is an evolving open standard. Expected developments include:

1. **Broader tool support**: More AI coding tools adopting the standard

2. **Enhanced MCP integration**: Deeper connections to external services

3. **Skill marketplace**: Official repository for discovering and installing skills

4. **Improved debugging tools**: Better visibility into skill execution

5. **Cross-agent compatibility**: Skills that work seamlessly across different AI tools

6. **Team collaboration features**: Shared skill libraries for organizations

7. **Advanced hooks**: More lifecycle points and richer context

8. **Performance optimizations**: Faster loading and execution

Stay updated by following Cursor's changelog and community announcements.

**Conclusion**

Agent Skills represent a powerful paradigm for extending AI coding agents with specialized capabilities. By packaging domain knowledge, workflows, and automation into reusable modules, skills enable agents to handle complex, project-specific tasks while maintaining clean context and focused behavior.

Key takeaways:

1. Skills are loaded dynamically when relevant, unlike always-on rules

2. [SKILL.md](http://SKILL.md) files combine YAML metadata with markdown instructions

3. Skills can be commands, agents, hooks, or MCP integrations

4. Hooks enable powerful automation patterns at key lifecycle points

5. Security and permissions should be carefully configured

6. Skills work best when focused on a single domain or workflow

7. The open standard enables cross-tool compatibility

Start simple: create one skill for a workflow you repeat frequently. Test it thoroughly, gather feedback, and iterate. As you become comfortable with the format, build more sophisticated skills that automate complex multi-step processes.

The future of AI-assisted development lies in specialized, context-aware capabilities that augment rather than replace developer expertise. Agent Skills provide the foundation for that future, today.

**Cursor Agent Skills: Advanced FAQ & Edge Cases**

A comprehensive guide addressing advanced, real-world workflow questions about Cursor Agent Skills that go beyond the basic documentation.

---

**1. PRECEDENCE & SCOPE**

**Q: What happens if a project-level skill has the same name as a user-level (global) skill?**

**Answer:** Project-level skills take precedence over global skills.[1] When the agent encounters a skill reference (either via natural language or slash command), it resolves to the project-local version first. This is a complete override, not a merge operation.

**Practical implications:**

- Use this intentionally to customize global skills for specific projects
- If you have a generic `git-workflow` skill globally, a project-specific one will completely replace it
- No conflict error is raised; the override is silent and deterministic

**Recommendation:** Document skill version numbers in your SKILL.md file to track which override is in effect, especially in team environments where multiple developers might be confused about which version is running.

---

**Q: Can a skill inherit from another skill?**

**Answer:** No, skills do not support explicit inheritance or extension relationships.[2] The concept of "Dependencies" in the SKILL.md refers to _external_ dependencies (like npm packages or shell tools), not skill-to-skill extension.

**Workaround patterns:**

1. **Copy-and-modify:** Duplicate logic and customize it for your needs. Version control the source skill so you can track divergence.
2. **Composition via instructions:** In your skill's `instructions` field, reference another skill and tell the agent how to invoke it.

```yaml
instructions: |
  For React testing, first use the /jest-base skill, then apply these React-specific patterns...
```

3. **Shared utilities:** Store common shell functions in a shared script that multiple skills source.

```bash
source /path/to/shared-functions.sh
```

**Why no inheritance?** Skills are meant to be self-contained, portable units compatible with Claude Code, other AI platforms, and the broader open standard. Inheritance would create tight coupling and reduce portability.

---

**2. ARGUMENT PARSING & INTERACTION**

**Q: How does the agent handle missing required arguments when invoked via natural language?**

**Answer:** The agent's behavior depends on the skill configuration and context:[3]

1. **If arguments are marked `required: true` in the command definition:**

- The agent will attempt to clarify interactively by asking you follow-up questions
- While awaiting your response, the agent can continue reading files or running other commands (per Cursor's Q&A improvements)
- The agent incorporates your answer once received

2. **If the agent is in Plan mode with clarification questions enabled:**

- The agent explicitly pauses and asks for missing arguments before proceeding

3. **If the skill lacks proper argument validation:**

- The skill execution may fail with an error, but the agent will be informed of the failure and can prompt you for clarification

**Best practice:** Always define your command arguments with clear `required` flags and helpful descriptions in the SKILL.md to enable the agent to prompt effectively.

---

**Q: Can skills persist data between invocations?**

**Answer:** Not directly within the skill execution context. Skills cannot maintain state across conversation turns without writing to persistent storage (filesystem).[4]

**Limitations:**

- Skill execution environment is ephemeral; variables do not persist between calls
- The mention of "caching" in documentation refers to Cursor's internal caching of LLM responses, not skill-level state persistence

**Persistent data workarounds:**

1. **Write to project files:**

```bash
# In your bashCommand
echo "$DATA" >> .cursor-skill-state/myskill.json
```

- The agent can then read this file in subsequent invocations
- Include these state files in `.cursorignore` if they should not pollute context

2. **Environment variables (limited):**

- Can pass data via environment variables during a single skill invocation
- Does not persist across separate skill calls
- Useful for inter-hook communication within one agent loop cycle

3. **Use subagents for stateful workflows:**

- Subagents are specifically designed to write state and resume with preserved context[5]
- Better approach for multi-step, stateful operations

**Advanced pattern:** Combine skills with subagents. The subagent can persist state in its session file, and the skill can invoke the subagent when stateful operations are needed.

---

**3. HOOKS & EXECUTION DETAILS**

**Q: Where are hook execution logs outputted?**

**Answer:** Hook logs appear in multiple places depending on how the hook is configured:[6]

1. **Standard output (stdout/stderr):**

- Redirected to Cursor's Agent Debug panel (Shift+Cmd+L on macOS, or Debug menu)
- Also visible in the terminal pane if the hook runs a bash command

2. **File-based logging:**

- If your hook script writes to a file, that file is not automatically shown in the UI
- You must explicitly read the log file (e.g., `tail -f ~/.cursor-hooks.log`) in the integrated terminal

3. **Hook JSON response:**

- The hook's return JSON is logged in the Agent Debug panel
- Look for `{"permission": "allow"}` or `{"continue": true}` entries

**Recommendation:** For persistent debugging, write hook output to a dedicated log file and create a skill command that displays recent logs:

```bash
# In hooks.json
{
  "type": "command",
  "command": "bash -c 'echo \"$(date): Hook executed\" >> ~/.cursor-hooks.log'"
}
```

---

**Q: What is the execution environment for the scripts?**

**Answer:** This depends on whether the sandbox is enabled:[7]

**With Sandbox enabled (macOS Seatbelt, default for Pro+ users):**

- Scripts run in a kernel-level sandbox with restricted capabilities
- **Read:** Workspace files, `/tmp`, and your filesystem (read-only, excluding cursorignore files)
- **Write:** Only to workspace and `/tmp` (NOT to `$HOME` or system directories)
- **Network:** Blocked entirely
- **Privileges:** Same as the user running Cursor, but constrained by the sandbox

**Without Sandbox (legacy allow-list mode):**

- Scripts run with full user shell privileges
- Full read/write access to the user's filesystem
- Network access is available
- All operations require explicit user approval (slower workflow)

**Security implications:**

- Sandboxed mode is stricter and safer for untrusted skills
- Scripts that write to `$HOME/.config`, `.ssh`, `.npmrc`, etc., will fail in sandboxed mode
- The agent cannot access sensitive credentials directly; it must request them via environment variables or explicit user prompts

**Best practice:** Test skills in sandboxed mode and use explicit environment variable injection for secrets (never hardcode credentials in skills).

---

**Q: Can a postToolUse hook modify the agent's response?**

**Answer:** Currently, postToolUse hooks can **observe** tool output but **cannot modify** it before it reaches the model.[8]

**What hooks CAN do:**

- Log and audit tool execution
- Trigger side effects (e.g., run a formatter after code edit)
- Block tool execution (via `"continue": false`)
- Collect metrics and monitoring data

**What hooks CANNOT do:**

- Transform or redact tool output before the model sees it
- Modify the tool's return value
- Strip sensitive data from output

**Workaround for output transformation:**

1. **Use a wrapper skill:** Create a skill that calls the original tool and pipes output through a transformation script

```bash
/original-command | jq '.result' | redact-secrets.sh
```

2. **Post-hook notification:** Use a postToolUse hook to notify the model (via logging) that certain output has been redacted, so it's aware of the filtering

3. **Feature request:** This is a requested feature[9] for Claude Code and may be added to Cursor in the future

---

**4. MCP (MODEL CONTEXT PROTOCOL) SPECIFICS**

**Q: How do I configure the actual connection to an MCP server?**

**Answer:** MCP server configuration is NOT handled in SKILL.md; it's configured in Cursor's settings (typically `~/.cursor/settings.json` or via the Cursor UI).[10]

**Configuration location:**

- Open Cursor settings (Cmd+, on macOS)
- Look for "MCP Servers" section
- Add your server configuration

**Configuration syntax for different server types:**

**1. Stdio-based servers (local command):**

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

**2. SSE (Server-Sent Events) servers (remote):**

```json
{
  "mcpServers": {
    "remote-server": {
      "url": "https://api.example.com/mcp"
    }
  }
}
```

**3. With environment variables (for sensitive data):**

```bash
#!/bin/bash
# Create a wrapper script (e.g., github-mcp-wrapper.sh)
export GITHUB_PERSONAL_ACCESS_TOKEN="your-token"
npx @modelcontextprotocol/server-github
```

Then reference in settings:

```json
{
  "mcpServers": {
    "github": {
      "command": "bash",
      "args": ["/path/to/github-mcp-wrapper.sh"]
    }
  }
}
```

**Environment variable interpolation in YAML/JSON:**

- Direct `${VAR}` syntax is **not supported** in Cursor settings[11]
- Use a wrapper script (as shown above) or docker with `.env` files
- Alternative: Use Smithery or other MCP package managers that handle env setup

**Token cost considerations:** Loading an MCP server adds significant overhead (16,000-43,000 tokens depending on schema complexity)[12], so only enable MCPs you actively use.

---

**5. CONTEXT & PERFORMANCE**

**Q: What is the token cost overhead of loading a skill?**

**Answer:** Skill loading cost depends on several factors:[13]

**Base cost:**

- Skill discovery: negligible (agent scans skill names, not full content)
- Skill invocation: The entire SKILL.md file is injected into context when the agent decides to use it

**Measured overhead:**

- A typical SKILL.md (500-1000 lines): approximately 1,000-3,000 tokens added to the context window
- Large skills with extensive bash commands and examples: approximately 5,000+ tokens
- This is a ONE-TIME cost per agent turn; the skill stays in context for the duration of the message

**Comparison to Rules:**

- Rules are **always** included in context (unavoidable cost)
- Skills are **dynamically** loaded only when relevant (lower average cost)

**Optimization strategies:**

1. **Keep instructions concise:** Use clear, concise language. Avoid redundant examples.
2. **Separate large scripts:** If a bash command is very long, link to an external script file instead of embedding it
3. **Use file references:** Instead of embedding entire examples, tell the agent to read example files

```yaml
instructions: |
  See `.skill-examples/react-pattern.ts` for the code style guide
```

4. **Token measurement:** Cursor 2.0+ shows token usage in the debug panel. Monitor loaded skills to identify expensive ones.

**Context window limits:**

- Claude Sonnet 4.5: 200,000 tokens (up to 400,000 in Max Mode)
- GPT-5: 400,000 tokens
- You can safely load 50+ typical skills before approaching limits in practical workflows

---

**6. FORMATTING & SYNTAX**

**Q: Does the YAML frontmatter support environment variable interpolation?**

**Answer:** Limited support. Depends on the field and context:[14]

**Supported interpolation:**

- **In bash commands:** Full shell variable expansion works

```yaml
commands:
  - name: 'deploy'
    bashCommand: |
      export ENV=${DEPLOY_ENV:-staging}
      npm run deploy:$ENV
```

Environment variables must be provided at hook/command runtime

- **In string fields (name, author, etc.):** ${VAR} syntax is **not supported**

```yaml
# This does NOT work:
author: '${USER}' # Will be literal "${USER}"
```

**Workarounds for environment-based configuration:**

1. **Template the SKILL.md at generation time:**

```bash
envsubst < SKILL.md.template > SKILL.md
```

2. **Read from environment in bash commands:**

```yaml
bashCommand: |
  author=$(echo $AUTHOR_NAME) # Use $author in your script
```

3. **Use wrapper scripts:** Create a script that reads env vars and calls the skill command

**Best practice:** For secrets and environment-specific data, use environment variable injection at the hook/command level, not in the SKILL.md file itself. This keeps skills portable and secure.

---

**7. SKILL DISCOVERY & AGENT BEHAVIOR**

**Q: How does the agent decide which skill to use?**

**Answer:** The agent uses semantic understanding combined with skill metadata:[15]

**Discovery mechanism:**

1. Agent reads the `when_to_use` field from each SKILL.md
2. Agent scans all loaded skills and identifies which ones match the current task context
3. Skills are loaded dynamically ONLY when the agent determines relevance
4. Multiple skills can be loaded in a single turn if the task requires them

**The `when_to_use` field:**

```yaml
when_to_use: |
  Use this skill when the user asks about testing React components, specifically when they mention Jest, unit tests, or test files. Not for E2E testing (use the Cypress skill instead).
```

**Precision matters:** The more specific your `when_to_use`, the more accurately the agent will load the skill at the right time. Vague descriptions lead to either unused skills or skills loaded unnecessarily.

**Fine-tuning skill discovery:**

- Include negative examples: "Not for X" helps the agent avoid confusion
- Reference other skills: "This pairs well with the React pattern skill"
- Be specific about task types: Instead of "database operations," say "PostgreSQL schema migrations using Knex"

---

**Q: Can I manually invoke a skill using a slash command?**

**Answer:** Yes. In Cursor 2.4+, skills are available in the slash command menu.[16]

**Usage:**

- Type `/` in the agent chat
- Scroll to find your skill or start typing the skill name
- Select the skill to invoke it directly
- The agent will execute it immediately, even if it wouldn't have chosen it automatically

**Slash command syntax:**

```
/skill-name [arguments]
```

If the skill has parameters, the agent will prompt you for them when invoked via slash command.

**Difference from natural language:**

- Slash command: Guarantees execution, bypasses `when_to_use` logic
- Natural language: Agent decides whether to use the skill based on task relevance

**Limitation:** Not all skills may appear in the slash menu if they are very new or if skill discovery is disabled. Refresh the skill list with Cmd+Shift+J.

---

**8. TEAM & PROJECT CONFIGURATION**

**Q: How should teams manage global vs. project-level skills?**

**Answer:** Follow this recommended hierarchy:[17]

**Global skills (user-level, `~/.cursor/skills/`):**

- Personal utilities that you use across all projects
- Language/framework fundamentals (if company-wide)
- Your custom tools and scripts
- Build once, use everywhere philosophy

**Project-level skills (`.cursor/skills/`):**

- Project-specific workflows (versioned with code)
- Team standards and conventions
- Project-local tools and scripts
- Git-versioned; shared with all developers on the team

**Team setup example:**

```
~/.cursor/skills/
├── rust-patterns/SKILL.md # Global: reusable Rust patterns
├── git-workflow/SKILL.md # Global: personal git config
└── terminal-utils/SKILL.md # Global: shell shortcuts

project-a/.cursor/skills/
├── deploy-staging/SKILL.md # Project-specific
├── database-migrations/SKILL.md # Project-specific
└── git-workflow/SKILL.md # Override: project-specific git rules

project-b/.cursor/skills/
├── mobile-testing/SKILL.md # Project-specific
└── api-development/SKILL.md # Project-specific
```

**Team rule:** Always version control project skills in `.cursor/skills/`. Never commit global skills; they're for personal use.

---

**9. COMMON TROUBLESHOOTING**

**Issue: Skill is not being discovered**

**Checklist:**

1. Ensure SKILL.md is in the correct location (`.cursor/skills/SKILL.md` or `~/.cursor/skills/SKILL.md`)
2. Verify YAML syntax is valid (use `yamllint`)
3. Check `when_to_use` field; maybe it's too restrictive
4. Refresh the skill list (Cmd+Shift+J on macOS)
5. Restart Cursor IDE

---

**Issue: Hook is not executing**

**Checklist:**

1. Verify hooks are defined in the correct skill or in a top-level `hooks.json`
2. Ensure the command/script file path is absolute or relative to the workspace root
3. Check permissions: is the script executable? (`chmod +x script.sh`)
4. Look at the Agent Debug panel for error messages
5. Test the hook script independently in the terminal

---

**Issue: Skill command takes too long or times out**

**Solution:**

- Set a `timeout` parameter if supported
- Break the command into smaller, parallelizable steps
- Use subagents for long-running operations
- Offload heavy computation to external services/MCPs

---

**10. ADVANCED PATTERNS**

**Pattern: Creating a skill that calls another skill**

**Approach:** Use slash command syntax within your skill instructions:

```yaml
instructions: |
  To set up a new React component:
  1. First, use the /create-component skill to scaffold the file
  2. Then, use the /add-tests skill to create the test file
  3. Finally, run the /format-code skill to ensure consistency
```

The agent will understand the sequence and execute the skills in order.

---

**Pattern: Skill that requires user input at multiple stages**

**Solution:** Use the agent's clarification question capability:

```yaml
bashCommand: |
  # Agent can pause here and ask for clarification
  # See Cursor docs on "Clarification questions from the agent"
  ask_question "Which environment should I deploy to?"
```

---

**Pattern: Conditional skill behavior based on project state**

**Example: Deploy skill that checks if tests pass first**

```yaml
bashCommand: |
  if [ -f "package.json" ]; then
    npm test || { echo "Tests failed, aborting deploy"; exit 1; }
    npm run deploy
  else
    echo "Not a Node.js project"
    exit 1
  fi
```

The agent will see the error and adapt accordingly.

---

**11. SECURITY BEST PRACTICES**

1. **Never hardcode secrets in skills** - Always use environment variables
2. **Keep scripts minimal** - Shorter code is easier to audit and less likely to have vulnerabilities
3. **Use sandboxed mode** - Enable the sandbox if available; it provides OS-level protection
4. **Test scripts independently** - Before adding to a skill, run scripts standalone to verify behavior
5. **Review before committing** - Team skills should go through code review like any other code
6. **Log sensibly** - Avoid logging sensitive data; be aware that logs may be visible in the Agent Debug panel

---

**12. MIGRATION & COMPATIBILITY**

**Upgrading from Rules to Skills**

If you have a `.cursorrules` file that might benefit from being a skill:

**Rules are better for:**

- Always-on context (language conventions, style guides)
- Global project instructions

**Skills are better for:**

- Procedural workflows (step-by-step "how-to" instructions)
- Domain-specific expertise (testing, deployment, etc.)
- Commands and bash scripts
- When you want dynamic, on-demand loading

**Action:** Analyze your `.cursorrules` file. Extract procedural sections into skills, keep contextual/informational sections as rules.

---

**13. FUTURE CONSIDERATIONS**

**Features under discussion or in development:**

- Skill inheritance/composition (not yet available)
- Output transformation hooks (feature requested)
- Persistent state management for skills (roadmap item)
- Skill marketplace/package management improvements

Monitor the Cursor forum and changelog for updates.

---

**REFERENCES**

[1] Local/project scope precedence: Project-level skills override global ones with no merge or error
[2] No skill inheritance: Skills do not support explicit inheritance; shared utilities use external scripts
[3] Agent clarification behavior: Cursor 2.4 includes clarification questions feature for missing arguments
[4] Skill state persistence: Skills are ephemeral; use filesystem or subagents for persistence
[5] Subagents for stateful workflows: Subagents write state and allow resumption with preserved context
[6] Hook logging locations: Logs appear in Agent Debug panel and terminal output
[7] Sandbox execution environment: macOS Seatbelt sandbox restricts read/write and network access
[8] PostToolUse hook limitations: Hooks cannot modify output before it reaches the model
[9] Hook output transformation feature request: Requested but not yet implemented
[10] MCP configuration location: Configured in Cursor settings, not in SKILL.md files
[11] Environment variable interpolation: Not supported in SKILL.md string fields; use wrapper scripts
[12] MCP token costs: MCP schemas add 16,000-43,000 tokens depending on complexity
[13] Skill context overhead: Typical skill adds 1,000-3,000 tokens; large skills can exceed 5,000
[14] YAML interpolation support: Shell expansion works in bashCommand; not in string fields
[15] Skill discovery mechanism: Agent-driven based on `when_to_use` semantic matching
[16] Slash command skill invocation: Available in Cursor 2.4+ via `/` menu
[17] Team skill configuration: Project-local skills are versioned; global skills are personal utilities

---

**Appendix: Quick Reference**

**Minimal [SKILL.md](http://SKILL.md) Template**

---

**name: my-skill**  
**version: 1.0.0**  
**description: Brief description of what this skill does**  
**when_to_use: Clear criteria for when to invoke this skill**

**Skill Instructions**

Your detailed instructions, workflows, and examples here.

**Common Hook Patterns**

**Run tests after agent finishes**:  
{  
"hooks": {  
"stop": \[{ "command": "npm test" }\]  
}  
}

**Format files after writing**:  
{  
"hooks": {  
"postToolUse": \[  
{  
"matcher": "fs_write",  
"command": "npm run format"  
}  
\]  
}  
}

**Log all bash commands**:  
{  
"hooks": {  
"preToolUse": \[  
{  
"matcher": "execute_bash",  
"command": "echo "$(date) \- $INPUT" \>\> .cursor/audit.log"  
}  
\]  
}  
}

**File Locations Cheat Sheet**

Project-level skills: .cursor/skills/SKILL-NAME/SKILL.md  
User-level skills: \~/.cursor/skills/SKILL-NAME/SKILL.md  
Hooks configuration: .cursor/hooks.json  
Hook scripts: .cursor/hooks/script-name.ts  
Rules (always-on): .cursor/rules/  
_.mdCommands: .cursor/commands/_.md  
Plans: .cursor/plans/\*.md

**Slash Command Summary**

/skill-name \- Invoke a specific skill  
/create-pr \- Example: Create pull request  
/code-review \- Example: Review code  
/tdd-workflow \- Example: Start TDD cycle

**Permission Categories**

permissions:  
filesystem: \# File read/write access  
network: \# External API calls  
tools: \# Cursor built-in tools  
bashCommands: \# Shell command restrictions

=== Cursor Sub Agents ===

**The Complete Guide to AI Subagents in Cursor**

**Executive Summary**

Subagents are specialized AI assistants that Cursor's main agent can delegate tasks to for improved performance and context management. Introduced in Cursor 2.4 (January 2026), subagents operate independently with their own context windows, run in parallel, and can be configured with custom prompts, tool access, and models\[1\]. This architectural innovation enables faster execution, more focused context management, and specialized expertise for complex development workflows.

**Introduction**

**What Are Subagents?**

Subagents are independent agents specialized to handle discrete parts of a parent agent's task\[1\]. Unlike the main agent that handles your primary conversation, subagents work behind the scenes on specific subtasks, returning only their final results to keep your main context clean and focused.

**Core characteristics:**

1. Independent operation with dedicated context windows

2. Parallel execution capabilities

3. Configurable prompts, tool access, and AI models

4. Automatic or manual invocation

5. Specialized expertise for specific task types

**Why Subagents Matter**

Traditional single-agent architectures face a fundamental scaling problem: complex tasks require X tokens of input context plus Y tokens of working context to produce Z token answers\[2\]. When running N tasks sequentially, this means (X \+ Y \+ Z) \* N tokens accumulate in your main context window, quickly exhausting available space and degrading performance.

Subagents solve this by farming out the (X \+ Y) \* N work to specialized agents that only return the final Z token answers\[2\]. This keeps the main conversation focused while enabling:

1. Faster overall execution through parallelization

2. Reduced context pollution in main agent

3. Better handling of long-running tasks

4. Specialized expertise without context overhead

5. Scalable multi-step workflows

**How Subagents Work**

**Execution Model**

Subagents operate on a delegation model where the main agent identifies suitable subtasks and spawns specialized subagents to handle them\[1\]. The workflow follows this pattern:

1. Main agent receives complex task from user

2. Agent analyzes task and identifies parallelizable components

3. Agent spawns one or more subagents with specific instructions

4. Subagents execute independently in parallel

5. Subagents return final results to main agent

6. Main agent synthesizes results and continues conversation

**Context isolation:** Each subagent maintains its own context window completely separate from the main agent\[1\]. This prevents context pollution and allows subagents to deeply explore specific areas without affecting the main conversation.

**Parallel execution:** Multiple subagents can run simultaneously, dramatically reducing total execution time for complex multi-part tasks\[3\]. This is particularly valuable for codebase research where different subagents can explore different modules concurrently.

**Tool access:** Subagents can be configured with specific tool permissions, ranging from full tool access (inheriting all tools from the main agent) to restricted subsets appropriate for their specialized role\[4\].

**Default Subagents**

Cursor includes several built-in subagents that automatically activate to improve agent conversations\[1\]:

| Subagent              | Purpose                                                                                                                              |
| :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| Codebase Research     | Deep exploration of codebase structure, patterns, and implementations. Spawned when agent needs to understand unfamiliar code areas. |
| Terminal Commands     | Executing shell commands and processing their output independently from main conversation flow.                                      |
| Parallel Work Streams | Breaking complex plans into parallel execution tracks that can proceed simultaneously.                                               |
| Explore               | Dedicated codebase exploration with ability to read files, search semantically, and build understanding of project structure.        |

Table 1: Default subagents included with Cursor

These default subagents work automatically in both the Cursor IDE editor and the Cursor CLI without requiring any configuration\[1\].

**Custom Subagent Configuration**

**File Structure and Location**

Custom subagents are defined in Markdown files with YAML frontmatter, stored in one of two locations\[4\]:

| Type          | Location                                 | Scope                | Priority |
| :------------ | :--------------------------------------- | :------------------- | :------- |
| Project-level | .cursor/agents/ or .claude/agents/       | Current project only | Highest  |
| User-level    | \~/.cursor/agents/ or \~/.claude/agents/ | All projects         | Lower    |

Table 2: Subagent configuration file locations

When project-level and user-level subagents share the same name, the project-level agent takes precedence\[4\]. This allows you to override global subagents with project-specific configurations.

**Note:** Cursor and Claude Code share the same subagent system, so .cursor/ and .claude/ directories are interchangeable\[5\].

**YAML Frontmatter Format**

Each subagent file follows this structure\[4\]:

---

**name: your-subagent-name**  
**description: A clear description of when this subagent should be used**  
**tools: tool1, tool2, tool3 \# Optional**  
**model: claude-opus-4.5 \# Optional**  
**is_background: true \# Optional**

Your subagent's system prompt goes here.

This section defines the subagent's role, capabilities, personality, and approach to solving problems. Include specific instructions, best practices, and any constraints the subagent should follow.

**Configuration fields:**

| Field         | Required | Description                                                                                                  |
| :------------ | :------- | :----------------------------------------------------------------------------------------------------------- |
| name          | Yes      | Unique identifier using lowercase letters and hyphens                                                        |
| description   | Yes      | Natural language description used by main agent for automatic delegation decisions                           |
| tools         | No       | Comma-separated list of specific tools. If omitted, inherits all tools from main agent including MCP servers |
| model         | No       | Specific AI model to use (e.g., claude-opus-4.5, claude-sonnet-4). Defaults to parent agent's model          |
| is_background | No       | If true, subagent runs continuously in background for monitoring tasks                                       |

Table 3: Subagent YAML frontmatter fields

**Creating Custom Subagents**

**Method 1: Using the /agents command (recommended)**

The /agents slash command provides an interactive interface for subagent management\[4\]:

/agents

This opens a menu where you can:

1. View all available subagents (built-in, user-level, and project-level)

2. Create new subagents with guided setup

3. Edit existing custom subagents including prompts and tool access

4. Delete custom subagents

5. Manage tool permissions with a complete list of available tools

The /agents command allows you to describe what you want and have Claude generate the initial subagent configuration, which you can then customize\[4\].

**Method 2: Manual file creation**

Create a new .md file in .cursor/agents/ or \~/.cursor/agents/ with the appropriate YAML frontmatter and system prompt:

---

**name: code-reviewer**  
**description: Specialized agent for thorough code review focusing on best practices, security, and maintainability**  
**tools: Read, Grep, SemanticSearch, WebSearch**  
**model: claude-opus-4.5**

You are an expert code reviewer with deep knowledge of software engineering best practices, security vulnerabilities, and code maintainability.

When reviewing code:

1. Check for security vulnerabilities and common attack vectors

2. Evaluate code maintainability and readability

3. Identify performance bottlenecks

4. Verify adherence to project coding standards

5. Suggest specific improvements with examples

Focus on actionable feedback that improves code quality without being overly prescriptive.

**Tool Configuration**

The tools field controls what actions the subagent can perform. Available tools include\[6\]:

**File operations:**

1. Read \- Read file contents

2. Write \- Create or overwrite files

3. StrReplace \- Make targeted string replacements

4. Delete \- Remove files

5. Glob \- List files matching patterns

6. LS \- List directory contents

**Search and analysis:**

1. Grep \- Search file contents with regex

2. SemanticSearch \- AI-powered codebase search

3. WebSearch \- Search the internet

4. WebFetch \- Retrieve web page contents

**Execution:**

1. Shell \- Execute terminal commands

2. EditNotebook \- Modify Jupyter notebooks

**Agent coordination:**

1. AskQuestion \- Request clarification from user

2. TodoWrite \- Create tasks for follow-up

3. Task \- Spawn additional subagents (when available)

**MCP integration:**

1. CallMcpTool \- Invoke Model Context Protocol tools

2. FetchMcpResource \- Retrieve MCP resources

3. ListMcpResources \- Enumerate available MCP resources

**Best practice:** Start with a minimal tool set appropriate for the subagent's specific role. This prevents misuse and keeps the subagent focused\[4\]. If you omit the tools field entirely, the subagent inherits all tools from the main agent.

**Invoking Subagents**

**Automatic Invocation**

The main agent automatically delegates to appropriate subagents based on their descriptions\[1\]. When you describe your subagent's purpose clearly in the description field, the agent will recognize when that expertise is needed and spawn the subagent automatically.

For example, if you have a code-reviewer subagent with description "Specialized agent for thorough code review focusing on best practices," the main agent will automatically invoke it when you request code review.

**Manual Invocation**

**Using slash commands:**

Invoke a specific subagent directly using the slash command syntax:

/code-reviewer

This immediately delegates the current conversation context to that subagent\[4\].

**Using the Task tool:**

The main agent can explicitly spawn subagents using the Task tool (when available)\[2\]\[6\]:

Task(subagent_type="code-reviewer", prompt="Review the authentication module")

**Note:** As of January 2026, there are reported issues with the Task tool not being consistently available in all Cursor versions and configurations\[6\]\[7\]. The Cursor team is actively working on this functionality.

**Through natural language:**

Simply ask the agent to use a specific subagent:

"Use the code-reviewer subagent to analyze the payment processing module."

The agent will attempt to delegate appropriately based on available subagents.

**Use Cases and Patterns**

**Parallel Execution Pattern**

Break complex features into parallel work streams that subagents can execute simultaneously\[1\]:

---

**name: parallel-implementer**  
**description: Breaks features into parallel subtasks and coordinates execution**  
**tools: Read, Write, StrReplace, Task**

You specialize in breaking complex features into independent parallel work streams.

When given a feature specification:

1. Analyze dependencies to identify parallelizable components

2. Create a clear task breakdown with 3-5 discrete work items

3. Spawn subagents to handle each work stream independently

4. Coordinate results and handle integration

Each subtask should be independent enough to execute in parallel.

**Example workflow:**

1. User requests: "Implement user authentication with OAuth, session management, and audit logging"

2. Parallel-implementer subagent spawns three subagents:

   - OAuth integration subagent

   - Session management subagent

   - Audit logging subagent

3. All three execute simultaneously

4. Main agent integrates results

**Deep Codebase Research Pattern**

Spawn multiple subagents to explore different parts of your codebase concurrently\[1\]:

---

**name: codebase-explorer**  
**description: Deep exploration of codebase structure, patterns, and dependencies**  
**tools: Read, Grep, SemanticSearch, Glob**  
**model: claude-sonnet-4**

You are a codebase archaeology expert who deeply understands code structure and patterns.

When exploring codebases:

1. Start with entry points and main modules

2. Map out architectural patterns and dependencies

3. Identify key abstractions and interfaces

4. Document unusual patterns or technical debt

5. Create a mental model of information flow

Provide comprehensive documentation of findings with specific file references.

This pattern is particularly valuable when working with large, unfamiliar codebases where multiple areas need simultaneous investigation.

**Master-Clone Architecture Pattern**

Rather than creating highly specialized subagents, use the main agent's full context in subagent clones\[2\]. Put all key context in CLAUDE.md or .cursorrules, then let the main agent dynamically spawn copies of itself via the Task tool.

**Advantages:**

1. Subagents have full project context from CLAUDE.md

2. Main agent controls orchestration dynamically

3. No need to maintain multiple specialized configurations

4. More flexible than rigid specialist subagents

**Implementation:**

Place comprehensive project context in .cursorrules:

**Project Context**

**Architecture**

\[Detailed architecture information\]

**Coding Standards**

\[Project-specific standards\]

**Common Patterns**

\[Reusable patterns in this codebase\]

Then let the main agent spawn clones as needed, each inheriting this full context.

**Background Monitoring Pattern**

Create subagents that run continuously in the background\[6\]:

---

**name: test-monitor**  
**description: Continuously monitors test suite health and reports failures**  
**tools: Shell, Read, AskQuestion**  
**is_background: true**

You are a test monitoring specialist who watches for test failures and regressions.

Continuously:

1. Monitor test execution results

2. Identify new failures or flaky tests

3. Alert user when issues are detected

4. Provide context on what changed

Keep the main agent informed of testing health without cluttering conversation.

Background subagents enable ongoing monitoring and alerting without requiring explicit invocation.

**Sequential Task Delegation Pattern**

Break features into sequential steps where each subagent builds on previous results:

async def orchestrate_feature(feature_spec: str):  
"""Break a feature into sub-tasks and delegate to agents."""

\# Step 1: Planning agent creates task breakdown  
plan \= await ask_cursor_agent(  
 f"Break this feature into 3-5 implementation tasks. "  
 f"Output as numbered list only:\\n\\n{feature_spec}",  
 verbose=False  
)

\# Step 2: Parse tasks  
tasks \= \[line.strip() for line in plan.split('\\n')  
 if line.strip() and line\[0\].isdigit()\]

\# Step 3: Execute each task with fresh agent  
results \= \[\]  
for task in tasks:  
 print(f"\\nExecuting: {task}")  
 result \= await ask_cursor_agent(  
 task,  
 auto_approve=True,  
 cwd='/path/to/project'  
 )  
 results.append({'task': task, 'result': result})

return results

This pattern is useful when tasks have dependencies and must execute in order\[5\].

**Skills vs Subagents**

Cursor 2.4 also introduced Skills, which are related but distinct from subagents\[1\]:

| Feature     | Skills                                                             | Subagents                                             |
| :---------- | :----------------------------------------------------------------- | :---------------------------------------------------- |
| Purpose     | Domain-specific knowledge and procedural "how-to" instructions     | Independent task execution with own context           |
| Activation  | Dynamically discovered and applied when relevant                   | Explicitly spawned for discrete subtasks              |
| Context     | Injected into main agent's context                                 | Separate isolated context window                      |
| File Format | SKILL.md files                                                     | .md files with YAML frontmatter in agents/ directory  |
| Best For    | Reusable workflows, specialized knowledge, procedural instructions | Parallel execution, deep research, long-running tasks |
| Execution   | Runs within main agent                                             | Runs as independent agent instance                    |

Table 4: Comparison of Skills and Subagents

**When to use Skills:** For domain-specific knowledge that should be available to the main agent when relevant contexts arise. Skills are like specialized knowledge modules that enhance the main agent's capabilities\[1\].

**When to use Subagents:** For discrete tasks that benefit from isolated context, parallel execution, or specialized tool access. Subagents are like team members you delegate complete subtasks to\[1\].

**Advanced Configurations**

**Model Selection Strategy**

Different models have different strengths. Configure subagents with appropriate models for their tasks:

**For deep reasoning and complex analysis:**  
model: claude-opus-4.5

**For faster execution on straightforward tasks:**  
model: claude-sonnet-4

**Inherit from parent (default):**

**Omit model field to use same model as parent agent**

Consider cost-performance tradeoffs: Opus models provide superior reasoning but cost more, while Sonnet models offer good performance at lower cost\[1\].

**Tool Access Patterns**

**Full access (inherit all tools):**

**Omit tools field**

**Read-only research:**  
tools: Read, Grep, SemanticSearch, WebSearch

**Write-capable implementation:**  
tools: Read, Write, StrReplace, Shell

**Coordination and delegation:**  
tools: Read, AskQuestion, Task, TodoWrite

Restricting tool access improves safety and keeps subagents focused on their intended role\[4\].

**Prompt Engineering for Subagents**

Effective subagent prompts follow these principles:

1. **Define clear role and expertise** \- Establish what the subagent specializes in

2. **Specify approach and methodology** \- Explain how the subagent should tackle tasks

3. **Set boundaries and constraints** \- Clarify what the subagent should NOT do

4. **Provide context on delegation** \- Explain the subagent's relationship to main agent

5. **Include examples when relevant** \- Show expected output formats or approaches

**Example prompt structure:**

You are a \[role\] with expertise in \[domain\].

When handling \[task type\]:

1. \[Step 1\]

2. \[Step 2\]

3. \[Step 3\]

Focus on \[key priorities\] while avoiding \[common pitfalls\].

Constraints:

- \[Constraint 1\]

- \[Constraint 2\]

Return results in \[format\] suitable for integration with main agent.

**Integration with MCP (Model Context Protocol)**

Subagents can leverage MCP servers to extend their capabilities\[8\]. When tools are omitted from the YAML frontmatter, subagents automatically inherit MCP tool access from the main agent\[4\].

**Enterprise governance:** Organizations can use hooks to monitor and control subagent MCP access\[8\]:

1. beforeMCPExecution hooks \- Validate and potentially block MCP calls before execution

2. afterMCPExecution hooks \- Scan responses for sensitive data, log usage patterns

3. Centralized MCP broker integration \- Route all MCP calls through governance layer

This enables organizations to maintain security and compliance while allowing subagents to leverage external tools and services.

**Troubleshooting**

**Common Issues**

**Task tool not available:**

As of January 2026, some users report the Task tool for spawning subagents is not consistently available\[6\]\[7\]. This appears to be related to:

1. Specific Cursor versions (particularly nightly and early access builds)

2. Model selection (may only work with certain models)

3. Plan tier (may require specific subscription levels)

4. Session context (may depend on agent mode)

**Workarounds:**

- Use automatic delegation by providing clear subagent descriptions

- Use /agent-name slash command syntax

- Ask agent explicitly to use specific subagent

- Ensure you're on a stable release version of Cursor

**YAML frontmatter removed when editing:**

Cursor IDE sometimes automatically removes YAML frontmatter when opening agent files\[9\]. To prevent this:

1. Edit agent files in external text editor

2. Use the /agents command for modifications instead of direct file editing

3. Create backup copies of agent configurations

**Custom subagents not recognized:**

If your custom subagents aren't being invoked:

1. Verify files are in correct location (.cursor/agents/ or \~/.cursor/agents/)

2. Check YAML frontmatter syntax is valid

3. Ensure name field uses lowercase and hyphens only

4. Verify description clearly explains when to use the subagent

5. Restart Cursor IDE after creating new subagents

6. Check that your plan supports custom subagents (usage-based plans should)

**Documentation pages returning errors:**

The official subagents documentation page ([cursor.com/docs/context/subagents](http://cursor.com/docs/context/subagents)) has returned client-side errors for some users\[7\]. Alternative information sources:

1. Cursor changelog: [cursor.com/changelog/2-4](http://cursor.com/changelog/2-4)

2. Forum discussions: [forum.cursor.com](http://forum.cursor.com)

3. Community guides and tutorials

**Best Practices**

**Design Principles**

**1\. Single Responsibility**

Each subagent should have one clear, focused purpose. Avoid creating subagents that try to do too many things\[4\].

**2\. Clear Descriptions**

The description field is critical for automatic delegation. Make it specific and action-oriented so the main agent knows exactly when to invoke the subagent\[4\].

**3\. Minimal Tool Sets**

Grant only the tools necessary for the subagent's role. This improves security and prevents unintended side effects\[4\].

**4\. Appropriate Model Selection**

Match model capability to task complexity. Use Opus for complex reasoning, Sonnet for routine tasks\[1\].

**5\. Context Inheritance**

Place shared project context in .cursorrules or CLAUDE.md so all subagents can access it\[2\].

**Organizational Strategies**

**Project-level subagents:**

Use .cursor/agents/ for:

1. Project-specific workflows

2. Domain knowledge unique to this codebase

3. Configurations that should be version controlled and shared with team

**User-level subagents:**

Use \~/.cursor/agents/ for:

1. Personal productivity workflows

2. Configurations that span multiple projects

3. Experimental subagents you're testing

**Naming conventions:**

1. Use descriptive hyphenated names: code-reviewer, test-writer, api-documenter

2. Avoid overly generic names: helper, utility, assistant

3. Include domain when relevant: react-refactorer, sql-optimizer

**Performance Optimization**

**Parallel work distribution:**

When tasks can run independently, explicit parallelization through subagents dramatically reduces total execution time\[3\]. Identify opportunities where multiple subagents can work simultaneously.

**Context budgeting:**

Each subagent has its own context window. Distribute context-heavy work across multiple subagents to avoid hitting context limits\[2\].

**Selective tool access:**

Limiting tools not only improves safety but also reduces the decision space for the subagent, leading to faster and more focused execution\[4\].

**Model tier selection:**

Use less expensive models for routine subagent tasks. Reserve Opus for subagents requiring complex reasoning\[1\].

**Enterprise Considerations**

**Security and Governance**

Organizations deploying Cursor at scale should consider:

**Access control:**

1. Define which subagents are available organization-wide

2. Restrict creation of custom subagents to appropriate roles

3. Audit subagent tool access permissions

**Monitoring:**

1. Track subagent invocation patterns

2. Monitor tool usage across subagents

3. Alert on unusual subagent behavior

**Compliance:**

1. Ensure subagents respect data access policies

2. Implement hooks to prevent access to sensitive resources

3. Maintain audit logs of subagent actions

**Team Collaboration**

**Shared subagent libraries:**

Version control subagent configurations in .cursor/agents/ so the entire team benefits from standardized workflows\[4\].

**Documentation:**

Maintain a team wiki documenting:

1. Available custom subagents

2. When to use each subagent

3. How to create new subagents

4. Best practices and lessons learned

**Review process:**

Establish code review practices for subagent configurations just as you would for application code. Review:

1. Tool access appropriateness

2. Prompt clarity and effectiveness

3. Model selection justification

4. Security implications

**Future Directions**

The subagent architecture opens possibilities for increasingly sophisticated AI-assisted development:

**Multi-agent collaboration:**

Future versions may enable subagents to communicate directly with each other rather than only through the main agent, enabling more sophisticated coordination patterns\[3\].

**Dynamic specialization:**

Subagents that automatically adapt their behavior based on project context and accumulated experience.

**Marketplace ecosystem:**

Community-contributed subagent templates for common development patterns, testing strategies, and domain-specific workflows.

**Enhanced orchestration:**

More sophisticated delegation logic where the main agent learns optimal subagent utilization patterns for your specific projects.

**Conclusion**

Subagents represent a fundamental architectural improvement in AI-assisted development. By enabling parallel execution, context isolation, and specialized expertise, they make Cursor's agent capable of handling increasingly complex and long-running development tasks.

Key takeaways:

1. Subagents enable parallel execution and better context management

2. Default subagents work automatically without configuration

3. Custom subagents provide project-specific specialized capabilities

4. Use /agents command for easiest subagent creation and management

5. Place shared context in .cursorrules for all subagents to access

6. Match model selection and tool access to subagent purpose

7. Subagents work in both Cursor IDE and Cursor CLI

As the subagent system matures and the community develops best practices, we can expect increasingly powerful multi-agent workflows that dramatically accelerate software development while maintaining code quality and security.

**References**

\[1\] Cursor. (2026, January 21). Cursor 2.4: Subagents, Skills, and Image Generation. [https://cursor.com/changelog/2-4](https://cursor.com/changelog/2-4)

\[2\] Shankar, S. (2025, November 1). How I Use Every Claude Code Feature. _Shrivu's Newsletter_. [https://blog.sshh.io/p/how-i-use-every-claude-code-feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)

\[3\] CursorAI. (2026, January 21). Cursor 2.4: Parallel Execution & Enhanced Capabilities \[LinkedIn post\]. [https://www.linkedin.com/posts/cursorai_cursor-now-uses-subagents-to-complete-parts-activity-7420199327010197504-GbUY](https://www.linkedin.com/posts/cursorai_cursor-now-uses-subagents-to-complete-parts-activity-7420199327010197504-GbUY)

\[4\] Kinney, S. (2025, July 28). Claude Code Sub-Agents. _Developing with AI Tools_. [https://stevekinney.com/courses/ai-development/claude-code-sub-agents](https://stevekinney.com/courses/ai-development/claude-code-sub-agents)

\[5\] Cursor Community Forum. (2026, January 27). How to Use Cursor-Agent from Inside Cursor IDE. [https://forum.cursor.com/t/this-might-help-some-folks-with-complex-workflows](https://forum.cursor.com/t/this-might-help-some-folks-with-complex-workflows)

\[6\] Cursor Community Forum. (2026, January 25). SubAgent invocation not working anymore on most recent nightly and early access builds. [https://forum.cursor.com/t/subagent-invocation-not-working-anymore-on-most-recent-nightly-and-early-access-builds/149987](https://forum.cursor.com/t/subagent-invocation-not-working-anymore-on-most-recent-nightly-and-early-access-builds/149987)

\[7\] Cursor Community Forum. (2026, January 23). Task Tool Missing for Custom Agents in .cursor/agents/. [https://forum.cursor.com/t/task-tool-missing-for-custom-agents-in-cursor-agents-documentation-pages-return-errors/149771](https://forum.cursor.com/t/task-tool-missing-for-custom-agents-in-cursor-agents-documentation-pages-return-errors/149771)

\[8\] Cursor. (2026). Hooks for security and platform teams. [https://cursor.com/changelog/2-4](https://cursor.com/changelog/2-4)

\[9\] Cursor Community Forum. (2026, January 12). IDE removing YAML frontmatter of agents. [https://forum.cursor.com/t/ide-removing-yaml-frontmatter-of-agents/148797](https://forum.cursor.com/t/ide-removing-yaml-frontmatter-of-agents/148797)

\[10\] Shah, S. (2026, January 15). Cursor just added sub-agents and skills \[LinkedIn post\]. [https://www.linkedin.com/posts/shreyshahh_cursor-just-added-sub-agents-and-skills-activity-7418044419792273408-XLgD](https://www.linkedin.com/posts/shreyshahh_cursor-just-added-sub-agents-and-skills-activity-7418044419792273408-XLgD)

=== Cursor Hooks ===

Here is a self‑contained reference guide to Cursor Agent Hooks as of early 2026, synthesizing Cursor docs plus the main third‑party deep dives and integration libraries. [cursor](https://cursor.com/docs/agent/hooks)

Where something is inferred from community behavior rather than the official docs, it is explicitly called out.

---

## 1. Mental model: what Cursor Hooks are

Cursor Hooks let you observe, control, and extend the agent loop by running your own scripts at specific lifecycle events. [infoq](https://www.infoq.com/news/2025/10/cursor-hooks/)

Key properties:

- Hooks are configured in JSON, in a `hooks.json` file
- For each hook event, Cursor spawns your command as a separate process
- The hook process:
  - Reads a single JSON payload from stdin
  - Optionally writes a single JSON response to stdout (depending on hook type)
  - Exits
- Communication is always JSON over stdio in both directions. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

Common use cases:

- Security and guardrails
  - Block dangerous shell commands
  - Deny certain MCP tool calls
  - Prevent leaking sensitive files to the LLM
- Observability and audit
  - Log every agent action to a file or external service
  - Build real‑time dashboards of agent behavior
- Workflow automation
  - Run until tests pass using the `stop` hook and auto follow‑ups
  - Trigger notifications when agents finish tasks
  - Integrate with CI, secrets managers, or code‑quality tools

Think of hooks as an event‑driven, local policy and automation layer that surrounds Cursor’s agent loop.

---

## 2. Where hooks are configured

You can define hooks at:

- Project level:
  - `$REPO/.cursor/hooks.json`
- Global level:
  - `~/.cursor/hooks.json` (Linux/macOS)
  - `C:\Users\<user>\.cursor\hooks.json` (Windows) [aiengineerguide](https://aiengineerguide.com/blog/cursor-agent-lifecycle-hooks/)

Cursor loads hooks from all applicable locations for a session. Every configured command for a given event will be run:

- If you define `stop` in both project and global config, all the `stop` commands from both files will be executed when the `stop` event fires. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

### 2.1 Basic `hooks.json` structure

Minimal schema looks like:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [{ "command": "./hooks/custom-script.sh" }],
    "stop": [{ "command": "bun run .cursor/hooks/track-stop.ts --stop" }]
  }
}
```

- `version` is currently `1` in all examples. [cursor](https://cursor.com/blog/agent-best-practices)
- `hooks` is a mapping from event name to an array of hook commands.
- Each hook command object must at least have:
  - `command`: the exact shell command Cursor should launch.

You can define multiple commands per event:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      { "command": "hooks/audit.sh" },
      { "command": "but cursor after-edit" }
    ],
    "stop": [{ "command": "but cursor stop" }]
  }
}
```

Both `afterFileEdit` commands will run on every file edit. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

---

## 3. Supported hook events

Based on Cursor docs, the official examples, and production harnesses (Cupcake, Gryph, GitButler), these are the core events you can rely on today. [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

### 3.1 Primary documented events

From Cursor docs and the main deep‑dive articles: [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

| Event                  | Category      | Can block? | Typical purpose                     |
| ---------------------- | ------------- | ---------: | ----------------------------------- |
| `beforeSubmitPrompt`   | Before action |        Yes | Guard or log user prompts           |
| `beforeShellExecution` | Before action |        Yes | Gate shell commands                 |
| `beforeMCPExecution`   | Before action |        Yes | Gate MCP tool calls                 |
| `beforeReadFile`       | Before action |        Yes | Gate sending file contents to LLM   |
| `afterShellExecution`  | After action  |         No | Observe shell output                |
| `afterMCPExecution`    | After action  |         No | Observe MCP results                 |
| `afterFileEdit`        | After action  |         No | Observe file edits                  |
| `afterAgentResponse`   | After action  |         No | Observe final agent replies         |
| `afterAgentThought`    | After action  |         No | Observe intermediate agent thoughts |
| `stop`                 | Lifecycle     |        Yes | Control agent loop continuation     |

This table is directly in line with the Cupcake Cursor harness, which implements Cursor hooks as documented behavior. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

### 3.2 Additional events used by security integrations

The Gryph adapter for Cursor references additional hook types for richer telemetry: [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

- `preToolUse`
- `postToolUse`
- `postToolUseFailure`
- `sessionStart`
- `sessionEnd`
- `subagentStart`
- `subagentStop`
- `preCompact`

These appear to be used by enterprise governance tooling and may not all be described in the public Cursor docs yet. They follow the same core pattern:

- Same common fields as the other hooks
- Extra event‑specific fields (tool details, session IDs, etc.)

For a “by the book” implementation, focus on the primary events table, and treat the extra ones as advanced or subject to change.

---

## 4. Common input payload shape

All hooks receive a JSON object over stdin. There is a common envelope shared across events plus event‑specific fields. [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

Common fields:

```json
{
  "hook_event_name": "beforeShellExecution",
  "conversation_id": "conv-123",
  "generation_id": "gen-456",
  "workspace_roots": ["/path/to/project"],
  "model": "gpt-4",
  "cursor_version": "2.0.77",
  "user_email": "user@example.com",
  "transcript_path": "/path/to/transcript.jsonl"
}
```

- `hook_event_name`: the event name (string)
- `conversation_id`: ID of the chat / agent session
- `generation_id`: ID for this agent run within the conversation
- `workspace_roots`: array of workspace root paths
- `model`: model identifier (optional)
- `cursor_version`: IDE / agent harness version (optional)
- `user_email`: signed‑in Cursor user email (optional)
- `transcript_path`: path to a transcript log file, used by some integrations (optional) [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Always key your logic off `hook_event_name` and then cast the rest of the payload according to event‑specific schemas below.

---

## 5. Event‑specific payloads and behavior

This section details each commonly documented event, its payload, and what responses Cursor expects.

### 5.1 `beforeSubmitPrompt`

When it fires:

- After the user hits “Enter” in the agent input, but before Cursor sends the prompt to the model. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

Payload shape (subset):

```json
{
  "hook_event_name": "beforeSubmitPrompt",
  "prompt": "do something super duper awesome",
  "attachments": [
    {
      "type": "file",
      "file_path": "path/to/open/file.rb"
    }
  ],
  "conversation_id": "668320d2-2fd8-4888-b33c-2a466fec86e7",
  "generation_id": "490b90b7-a2ce-4c2c-bb76-cb77b125df2f",
  "workspace_roots": ["/Users/alice/projects/example"]
}
```

Capabilities:

- Can block or allow the prompt
- Cannot modify the prompt
- Cannot inject extra context into the model input (there is an open feature request to add that). [forum.cursor](https://forum.cursor.com/t/hooks-allow-beforesubmitprompt-hook-to-inject-additional-context/150707)

Allowed response:

```json
// Allow submission
{ "continue": true }

// Block submission and show a message to the user
{
  "continue": false,
  "user_message": "Prompt blocked by policy"
}
```

- Only `continue` and optional `user_message` are honored here. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)
- Context injection via extra fields like `additional_context` is explicitly not supported. [forum.cursor](https://forum.cursor.com/t/hooks-allow-beforesubmitprompt-hook-to-inject-additional-context/150707)

Typical uses:

- Prompt safety checks
- Enforcing internal usage policies
- Prompt‑level analytics and metrics

---

### 5.2 `beforeShellExecution`

When it fires:

- Immediately before any shell command the agent wants to run. [infoq](https://www.infoq.com/news/2025/10/cursor-hooks/)

Payload shape:

```json
{
  "hook_event_name": "beforeShellExecution",
  "conversation_id": "668320d2-2fd8-4888-b33c-2a466fec86e7",
  "generation_id": "490b90b7-a2ce-4c2c-bb76-cb77b125df2f",
  "command": "git status",
  "cwd": "/Users/alice/projects/example",
  "workspace_roots": ["/Users/alice/projects/example"]
}
```

Capabilities:

- Can allow, deny, or “ask” for user confirmation. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

Response format (snake_case fields per Cupcake): [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

```json
// Allow
{ "permission": "allow" }

// Deny with messages
{
  "permission": "deny",
  "user_message": "Command blocked by policy",
  "agent_message": "Policy BLOCK-001 triggered"
}

// Ask user to confirm (if supported by current Cursor version)
{
  "permission": "ask",
  "question": "Allow system modification?",
  "user_message": "Requires approval"
}
```

Notes:

- Response fields should be snake_case (`user_message`, `agent_message`), even though some early blog posts used camelCase. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)
- On invalid or missing response, integrators like Cupcake recommend treating it as “allow” for safety of workflow. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Typical uses:

- Block destructive commands such as `rm -rf` or `curl | sh`
- Force user confirmation on dangerous operations
- Send shell command audit logs to security systems

---

### 5.3 `beforeMCPExecution`

When it fires:

- Before executing an MCP tool call (for example, a tool that interacts with external systems). [cursor](https://cursor.com/blog/agent-best-practices)

Payload shape (from GitButler and Cupcake): [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

```json
{
  "hook_event_name": "beforeMCPExecution",
  "server": "my-mcp-server",
  "tool_name": "database_query",
  "tool_input": "{\"query\": \"SELECT * FROM users\"}",
  "command": "but", // MCP server command
  "workspace_roots": ["/Users/alice/projects/example"],
  "conversation_id": "conv-123",
  "generation_id": "gen-456"
}
```

- `tool_input` is typically an escaped JSON string of the tool parameters. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

Response format:

- Same as `beforeShellExecution`:

```json
// Allow
{ "permission": "allow" }

// Deny
{
  "permission": "deny",
  "user_message": "MCP call blocked by policy",
  "agent_message": "External database access disabled"
}
```

Typical uses:

- Guard access to external services or sensitive APIs
- Enforce tenancy or RBAC policies on tools
- Track which tools the agent is using over time

---

### 5.4 `beforeReadFile`

When it fires:

- Before Cursor reads a file and ships its contents to the model. [infoq](https://www.infoq.com/news/2025/10/cursor-hooks/)

Payload shape:

```json
{
  "hook_event_name": "beforeReadFile",
  "file_path": "/path/to/secrets.env",
  "content": "API_KEY=...",
  "attachments": [
    {
      "type": "file",
      "filePath": "/path/to/.cursorrules"
    }
  ],
  "conversation_id": "conv-123",
  "generation_id": "gen-456"
}
```

Capabilities:

- Can allow or deny reading this file
- Cannot send user or agent messages; this is a pure permission decision. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Response format:

```json
// Allow this file to be read and sent to the model
{ "permission": "allow" }

// Deny reading this file
{ "permission": "deny" }
```

This hook is central for data‑loss prevention and redacting secrets before they leave the local machine. [infoq](https://www.infoq.com/news/2025/10/cursor-hooks/)

---

### 5.5 `afterShellExecution`

When it fires:

- After a shell command completes. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterShellExecution",
  "command": "npm install express",
  "cwd": "/path/to/project",
  "output": "...", // stdout / stderr
  "duration": 150 // ms
}
```

Capabilities:

- Purely observe; cannot block or modify anything.
- Response is ignored; you should return `{}` for cleanliness. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Use cases:

- Logging command output to external systems
- Computing metrics on runtime and success rates
- Security analytics

---

### 5.6 `afterMCPExecution`

When it fires:

- After an MCP tool call finishes. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterMCPExecution",
  "tool_name": "database_query",
  "tool_input": "{\"query\": \"SELECT * FROM users\"}",
  "result_json": "...", // tool result JSON
  "duration": 250 // ms
}
```

Like `afterShellExecution`, this is fire‑and‑forget. Response is ignored (`{}`).

Typical uses:

- Logging external side effects
- Alerting on slow or failing tools
- Cost accounting for MCP calls

---

### 5.7 `afterFileEdit`

When it fires:

- After Cursor edits a file through the agent. [aiengineerguide](https://aiengineerguide.com/blog/cursor-agent-lifecycle-hooks/)

Payload shape:

```json
{
  "hook_event_name": "afterFileEdit",
  "file_path": "/path/to/main.ts",
  "edits": [
    {
      "old_string": "const foo = 1",
      "new_string": "const foo = 2"
    }
  ]
}
```

Capabilities:

- Observe file changes
- Response is ignored; return `{}`. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Use cases:

- Auto‑running formatters or linters (via external orchestrator)
- Sending diffs to code review tools
- SAST or dependency scanning on modified files

---

### 5.8 `afterAgentResponse`

When it fires:

- After the agent has produced a natural language response for the user. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterAgentResponse",
  "text": "Here's the fix for the bug..."
}
```

Capabilities:

- Pure telemetry; response ignored.

Use cases:

- Logging agent responses to a knowledge base
- Safety filters or tone analysis that run out‑of‑band
- Analytics about response length and content

---

### 5.9 `afterAgentThought`

When it fires:

- After an internal “thought” step of the agent, before user‑visible output. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterAgentThought",
  "text": "I need to analyze the code structure...",
  "duration_ms": 1500
}
```

Use cases:

- Fine‑grained tracing of the agent loop
- Performance profiling: how long each reasoning step takes
- Advanced debugging of complex multi‑step plans

---

### 5.10 `stop`

When it fires:

- When the task is completed from the agent’s perspective. This is the main lifecycle hook for controlling “run until done” loops. [cursor](https://cursor.com/blog/agent-best-practices)

Payload shape:

```json
{
  "hook_event_name": "stop",
  "status": "completed", // or "aborted", "error"
  "loop_count": 2
}
```

- `status`:
  - `completed`: agent believes it finished successfully
  - `aborted`: user or environment aborted
  - `error`: some failure occurred
- `loop_count`: number of auto‑followups already triggered. Cursor enforces a maximum of 5 auto follow‑ups. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Response format:

```json
// Allow agent to stop; no further action
{}

// Continue agent loop with an auto follow‑up
{
  "followup_message": "Tests are still failing. Please fix them."
}
```

Behavior:

- If `followup_message` is present:
  - Cursor submits it as the next user message
  - The agent loop continues
  - `loop_count` is incremented
  - Once `loop_count` reaches Cursor’s limit (5), additional follow‑ups are ignored. [cursor](https://cursor.com/blog/agent-best-practices)

Typical uses:

- “Run until tests pass” pattern
  - At `stop`, check external test status and, if failing, return a follow‑up message instructing the agent to keep fixing. [cursor](https://cursor.com/blog/agent-best-practices)
- Long‑running workflows that need a human or external signal to declare success
- Enforcement that certain checks have been run before final completion

---

## 6. Response formats, casing, and validation

Key conventions: [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

- Response fields are snake_case, not camelCase:
  - `user_message`, `agent_message`, `followup_message`
- Only certain events support messages or control fields:

  - Permission events:
    - `beforeShellExecution`
    - `beforeMCPExecution`
    - `beforeReadFile` (permission only)
  - Prompt gate:
    - `beforeSubmitPrompt` (`continue`, optional `user_message`)
  - Loop control:
    - `stop` (`followup_message`)
  - All other events:
    - Respond with `{}` or nothing; output is ignored.

- Integrations like Gryph model decision types as an enum:
  - `allow`, `deny`, `ask` for permission events. [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

Example universal pattern in a Python hook script: [forum.cursor](https://forum.cursor.com/t/hooks-still-not-working-properly-in-2-1-6/143417)

```python
#!/usr/bin/env python3
import json
import sys

def handle_event(event):
    name = event.get("hook_event_name")

    if name in ("beforeShellExecution", "beforeMCPExecution"):
        cmd = event.get("command") or event.get("tool_name")
        if cmd and "rm -rf" in cmd:
            return {
                "permission": "deny",
                "user_message": "Dangerous command blocked",
                "agent_message": "Policy BLOCK-DANGEROUS triggered"
            }
        return {"permission": "allow"}

    if name == "beforeReadFile":
        path = event.get("file_path", "")
        if "secrets" in path or path.endswith(".env"):
            return {"permission": "deny"}
        return {"permission": "allow"}

    if name == "beforeSubmitPrompt":
        prompt = event.get("prompt", "")
        if "company-secret" in prompt:
            return {
                "continue": False,
                "user_message": "Prompt blocked for containing sensitive keywords"
            }
        return {"continue": True}

    if name == "stop":
        status = event.get("status")
        loop_count = event.get("loop_count", 0)
        if status == "completed" and loop_count < 5:
            # Example: ask agent to re-run tests
            return {
                "followup_message": "Please re-run the tests and fix any failures."
            }
        return {}

    # Fire-and-forget events
    return {}

def main():
    raw = sys.stdin.read()
    if not raw.strip():
        return

    try:
        event = json.loads(raw)
    except json.JSONDecodeError:
        # Fail open
        print(json.dumps({"permission": "allow"}))
        return

    response = handle_event(event)
    if response is not None:
        print(json.dumps(response))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
```

---

## 7. Execution model and operational considerations

Although Cursor does not publish a fully formal “execution semantics” spec, the docs and community examples provide enough signal to reason about behavior. [forum.cursor](https://forum.cursor.com/t/cursor-hooks-on-windows/140293)

### 7.1 Process model

For each configured hook command:

- Cursor spawns a separate process (your `command`)
- Writes a single JSON payload to its stdin
- Waits for stdout
- Parses a single JSON response if the event supports responses
- Treats unexpected output or failure conservatively:
  - For permission events, most harnesses treat malformed output as “allow” or “continue” for safety of development workflows. [forum.cursor](https://forum.cursor.com/t/hooks-still-not-working-properly-in-2-1-6/143417)

Hooks are local:

- All scripts run with the privileges of your local user account
- There is no “remote hooks” feature built into Cursor; remote behavior is something your hook script can implement (for example, by calling an HTTP API)

### 7.2 Performance

Best practices:

- Keep hooks fast, especially blocking ones (`before*`, `stop`)
  - Aim for under 100–200 ms where possible
- Do heavy work asynchronously:
  - Forward events to a local agent or queue
  - Store data in a local file and process later

If hooks are too slow, they will degrade the agent experience because they run at key steps like every shell command or file read.

### 7.3 Cross‑platform quirks

From bug reports and examples: [forum.cursor](https://forum.cursor.com/t/cursor-hooks-on-windows/140293)

- Windows quoting is tricky when using inline `echo` JSON:
  - Use a real script file (`.ps1`, `.cmd`, or Python) instead of raw `echo '{...}'`
- Make sure script paths are correct for the OS:
  - Example on Windows:
    ```json
    {
      "version": 1,
      "hooks": {
        "beforeSubmitPrompt": [
          {
            "command": "C:\\Users\\cnd\\AppData\\Roaming\\Python\\Python312\\python.exe .\\log_cursor_hook.py"
          }
        ]
      }
    }
    ```
- Ensure scripts are executable on Unix systems:
  - `chmod +x ~/.cursor/hooks/custom-script.sh`. [aiengineerguide](https://aiengineerguide.com/blog/cursor-agent-lifecycle-hooks/)

---

## 8. Concrete patterns and examples

### 8.1 Block dangerous shell commands

`~/.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      { "command": "~/.cursor/hooks/block-dangerous-shell.py" }
    ]
  }
}
```

`~/.cursor/hooks/block-dangerous-shell.py` (simplified):

```python
#!/usr/bin/env python3
import json, sys

DANGEROUS = ["rm -rf", ":(){", "mkfs", "diskutil eraseDisk"]

event = json.loads(sys.stdin.read())
cmd = event.get("command", "")

if any(term in cmd for term in DANGEROUS):
    print(json.dumps({
        "permission": "deny",
        "user_message": "Blocked dangerous shell command",
        "agent_message": "Command denied by security policy"
    }))
else:
    print(json.dumps({"permission": "allow"}))
```

This implements the policy example that shows up in Cupcake’s docs and common Rego policies. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

---

### 8.2 Run until tests pass with `stop`

Project `.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "stop": [{ "command": "bun run .cursor/hooks/grind.ts" }]
  }
}
```

`.cursor/hooks/grind.ts` implements:

- At `stop`:
  - Check external test status (for example, from a file or CI API)
  - If tests are failing and `loop_count < 5`, return a `followup_message` instructing the agent to keep fixing
  - Otherwise, return `{}` to allow the agent to end

Cursor’s own documentation and best‑practices guide highlight this “long‑running agent loop” pattern explicitly. [cursor](https://cursor.com/docs/cookbook/agent-workflows)

---

### 8.3 Observability and tracing

A generic logger hook (Python), similar to the detailed community example: [reddit](https://www.reddit.com/r/cursor/comments/1qd20ty/using_cursors_hidden_hooks_system_for_realtime/)

- Attach it to multiple events:

  - `beforeShellExecution`
  - `afterShellExecution`
  - `afterFileEdit`
  - `afterAgentResponse`
  - `stop`

- In the script:
  - Parse the JSON
  - Write a sanitized line to `hook_calls.txt`
  - Optionally send data to OpenTelemetry, Datadog, or a home‑grown dashboard

This gives you real‑time traces like:

- Agent sessions and durations
- All commands run and their outputs
- Files edited and their diffs
- Final statuses and reasons for stop

---

## 9. Advanced hooks and enterprise harnesses

Third‑party security and governance systems (Gryph, Cupcake, Runlayer, etc.) use Cursor hooks as an input to their unified event stream. [cursor](https://cursor.com/blog/hooks-partners)

Additional event types from Gryph’s adapter: [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

- `sessionStart` and `sessionEnd`
  - Extra fields: `session_id`, `is_background_agent`, `composer_mode`, durations, error messages
- `preToolUse`, `postToolUse`, `postToolUseFailure`
  - Cross‑tool events across Cursor’s internal tools
- `subagentStart`, `subagentStop`
  - For multi‑agent systems
- `preCompact`
  - Likely for context compaction events

If you are building deep governance or org‑wide agent monitoring, studying those harnesses can give you practical schemas and patterns. For most end‑users, the documented event set in section 5 is sufficient and less likely to change.

---

## 10. Practical checklist for using Cursor Hooks

For a robust setup:

1. Decide scope
   - Global policy hooks in `~/.cursor/hooks.json`
   - Project‑specific hooks in `$REPO/.cursor/hooks.json`
2. Start with these events:
   - `beforeShellExecution`
   - `beforeMCPExecution`
   - `beforeReadFile`
   - `beforeSubmitPrompt`
   - `stop`
3. Implement scripts in a real language (Python, TS, Go)
   - Avoid single‑line `echo` JSON, especially on Windows
   - Validate and handle JSON errors gracefully
4. Enforce snake_case in response fields
   - `permission`, `user_message`, `agent_message`, `followup_message`, `continue`, `question`
5. Fail open or fail closed, consciously
   - For dev environments, fail open (allow) on hook failure
   - For production CI or gated flows, consider failing closed
6. Log everything during early development
   - Use `after*` hooks to debug behavior before you start blocking actions
7. Add guardrails incrementally
   - Start with logging only
   - Then block obviously bad actions
   - Then introduce ask/deny flows

Following this pattern lets you align very closely with Cursor’s Hooks documentation and the real‑world integrations that have evolved around it, without relying on fragile, undocumented behavior.
