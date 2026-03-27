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

| Subagent | Purpose |
| :---- | :---- |
| Codebase Research | Deep exploration of codebase structure, patterns, and implementations. Spawned when agent needs to understand unfamiliar code areas. |
| Terminal Commands | Executing shell commands and processing their output independently from main conversation flow. |
| Parallel Work Streams | Breaking complex plans into parallel execution tracks that can proceed simultaneously. |
| Explore | Dedicated codebase exploration with ability to read files, search semantically, and build understanding of project structure. |

Table 1: Default subagents included with Cursor

These default subagents work automatically in both the Cursor IDE editor and the Cursor CLI without requiring any configuration\[1\].

**Custom Subagent Configuration**

**File Structure and Location**

Custom subagents are defined in Markdown files with YAML frontmatter, stored in one of two locations\[4\]:

| Type | Location | Scope | Priority |
| :---- | :---- | :---- | :---- |
| Project-level | .cursor/agents/ or .claude/agents/ | Current project only | Highest |
| User-level | \~/.cursor/agents/ or \~/.claude/agents/ | All projects | Lower |

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
**is\_background: true \# Optional**

Your subagent's system prompt goes here.

This section defines the subagent's role, capabilities, personality, and approach to solving problems. Include specific instructions, best practices, and any constraints the subagent should follow.

**Configuration fields:**

| Field | Required | Description |
| :---- | :---- | :---- |
| name | Yes | Unique identifier using lowercase letters and hyphens |
| description | Yes | Natural language description used by main agent for automatic delegation decisions |
| tools | No | Comma-separated list of specific tools. If omitted, inherits all tools from main agent including MCP servers |
| model | No | Specific AI model to use (e.g., claude-opus-4.5, claude-sonnet-4). Defaults to parent agent's model |
| is\_background | No | If true, subagent runs continuously in background for monitoring tasks |

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

Task(subagent\_type="code-reviewer", prompt="Review the authentication module")

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

   * OAuth integration subagent

   * Session management subagent

   * Audit logging subagent

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
**is\_background: true**

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

async def orchestrate\_feature(feature\_spec: str):  
"""Break a feature into sub-tasks and delegate to agents."""

\# Step 1: Planning agent creates task breakdown  
plan \= await ask\_cursor\_agent(  
    f"Break this feature into 3-5 implementation tasks. "  
    f"Output as numbered list only:\\n\\n{feature\_spec}",  
    verbose=False  
)

\# Step 2: Parse tasks  
tasks \= \[line.strip() for line in plan.split('\\n')   
         if line.strip() and line\[0\].isdigit()\]

\# Step 3: Execute each task with fresh agent  
results \= \[\]  
for task in tasks:  
    print(f"\\nExecuting: {task}")  
    result \= await ask\_cursor\_agent(  
        task,  
        auto\_approve=True,  
        cwd='/path/to/project'  
    )  
    results.append({'task': task, 'result': result})

return results

This pattern is useful when tasks have dependencies and must execute in order\[5\].

**Skills vs Subagents**

Cursor 2.4 also introduced Skills, which are related but distinct from subagents\[1\]:

| Feature | Skills | Subagents |
| :---- | :---- | :---- |
| Purpose | Domain-specific knowledge and procedural "how-to" instructions | Independent task execution with own context |
| Activation | Dynamically discovered and applied when relevant | Explicitly spawned for discrete subtasks |
| Context | Injected into main agent's context | Separate isolated context window |
| File Format | SKILL.md files | .md files with YAML frontmatter in agents/ directory |
| Best For | Reusable workflows, specialized knowledge, procedural instructions | Parallel execution, deep research, long-running tasks |
| Execution | Runs within main agent | Runs as independent agent instance |

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

* \[Constraint 1\]

* \[Constraint 2\]

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

* Use automatic delegation by providing clear subagent descriptions

* Use /agent-name slash command syntax

* Ask agent explicitly to use specific subagent

* Ensure you're on a stable release version of Cursor

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

\[2\] Shankar, S. (2025, November 1). How I Use Every Claude Code Feature. *Shrivu's Newsletter*. [https://blog.sshh.io/p/how-i-use-every-claude-code-feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)

\[3\] CursorAI. (2026, January 21). Cursor 2.4: Parallel Execution & Enhanced Capabilities \[LinkedIn post\]. [https://www.linkedin.com/posts/cursorai\_cursor-now-uses-subagents-to-complete-parts-activity-7420199327010197504-GbUY](https://www.linkedin.com/posts/cursorai_cursor-now-uses-subagents-to-complete-parts-activity-7420199327010197504-GbUY)

\[4\] Kinney, S. (2025, July 28). Claude Code Sub-Agents. *Developing with AI Tools*. [https://stevekinney.com/courses/ai-development/claude-code-sub-agents](https://stevekinney.com/courses/ai-development/claude-code-sub-agents)

\[5\] Cursor Community Forum. (2026, January 27). How to Use Cursor-Agent from Inside Cursor IDE. [https://forum.cursor.com/t/this-might-help-some-folks-with-complex-workflows](https://forum.cursor.com/t/this-might-help-some-folks-with-complex-workflows)

\[6\] Cursor Community Forum. (2026, January 25). SubAgent invocation not working anymore on most recent nightly and early access builds. [https://forum.cursor.com/t/subagent-invocation-not-working-anymore-on-most-recent-nightly-and-early-access-builds/149987](https://forum.cursor.com/t/subagent-invocation-not-working-anymore-on-most-recent-nightly-and-early-access-builds/149987)

\[7\] Cursor Community Forum. (2026, January 23). Task Tool Missing for Custom Agents in .cursor/agents/. [https://forum.cursor.com/t/task-tool-missing-for-custom-agents-in-cursor-agents-documentation-pages-return-errors/149771](https://forum.cursor.com/t/task-tool-missing-for-custom-agents-in-cursor-agents-documentation-pages-return-errors/149771)

\[8\] Cursor. (2026). Hooks for security and platform teams. [https://cursor.com/changelog/2-4](https://cursor.com/changelog/2-4)

\[9\] Cursor Community Forum. (2026, January 12). IDE removing YAML frontmatter of agents. [https://forum.cursor.com/t/ide-removing-yaml-frontmatter-of-agents/148797](https://forum.cursor.com/t/ide-removing-yaml-frontmatter-of-agents/148797)

\[10\] Shah, S. (2026, January 15). Cursor just added sub-agents and skills \[LinkedIn post\]. [https://www.linkedin.com/posts/shreyshahh\_cursor-just-added-sub-agents-and-skills-activity-7418044419792273408-XLgD](https://www.linkedin.com/posts/shreyshahh_cursor-just-added-sub-agents-and-skills-activity-7418044419792273408-XLgD)
