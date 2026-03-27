Here is a self‑contained reference guide to Cursor Agent Hooks as of early 2026, synthesizing Cursor docs plus the main third‑party deep dives and integration libraries. [cursor](https://cursor.com/docs/agent/hooks)

Where something is inferred from community behavior rather than the official docs, it is explicitly called out.

***

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

***

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
    "afterFileEdit": [
      { "command": "./hooks/custom-script.sh" }
    ],
    "stop": [
      { "command": "bun run .cursor/hooks/track-stop.ts --stop" }
    ]
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
    "stop": [
      { "command": "but cursor stop" }
    ]
  }
}
```

Both `afterFileEdit` commands will run on every file edit. [blog.gitbutler](https://blog.gitbutler.com/cursor-hooks-deep-dive)

***

## 3. Supported hook events

Based on Cursor docs, the official examples, and production harnesses (Cupcake, Gryph, GitButler), these are the core events you can rely on today. [pkg.go](https://pkg.go.dev/github.com/safedep/gryph/agent/cursor)

### 3.1 Primary documented events

From Cursor docs and the main deep‑dive articles: [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

| Event                | Category        | Can block? | Typical purpose                            |
|----------------------|-----------------|-----------:|--------------------------------------------|
| `beforeSubmitPrompt` | Before action   | Yes        | Guard or log user prompts                  |
| `beforeShellExecution` | Before action | Yes        | Gate shell commands                         |
| `beforeMCPExecution` | Before action   | Yes        | Gate MCP tool calls                         |
| `beforeReadFile`     | Before action   | Yes        | Gate sending file contents to LLM          |
| `afterShellExecution` | After action   | No         | Observe shell output                        |
| `afterMCPExecution`  | After action    | No         | Observe MCP results                         |
| `afterFileEdit`      | After action    | No         | Observe file edits                          |
| `afterAgentResponse` | After action    | No         | Observe final agent replies                 |
| `afterAgentThought`  | After action    | No         | Observe intermediate agent thoughts         |
| `stop`               | Lifecycle       | Yes        | Control agent loop continuation             |

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

***

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

***

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

***

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

***

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
  "command": "but",           // MCP server command
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

***

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

***

### 5.5 `afterShellExecution`

When it fires:

- After a shell command completes. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterShellExecution",
  "command": "npm install express",
  "cwd": "/path/to/project",
  "output": "...",     // stdout / stderr
  "duration": 150      // ms
}
```

Capabilities:

- Purely observe; cannot block or modify anything.
- Response is ignored; you should return `{}` for cleanliness. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Use cases:

- Logging command output to external systems
- Computing metrics on runtime and success rates
- Security analytics

***

### 5.6 `afterMCPExecution`

When it fires:

- After an MCP tool call finishes. [cupcake.eqtylab](https://cupcake.eqtylab.io/reference/harnesses/cursor/)

Payload shape:

```json
{
  "hook_event_name": "afterMCPExecution",
  "tool_name": "database_query",
  "tool_input": "{\"query\": \"SELECT * FROM users\"}",
  "result_json": "...",   // tool result JSON
  "duration": 250         // ms
}
```

Like `afterShellExecution`, this is fire‑and‑forget. Response is ignored (`{}`).

Typical uses:

- Logging external side effects
- Alerting on slow or failing tools
- Cost accounting for MCP calls

***

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

***

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

***

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

***

### 5.10 `stop`

When it fires:

- When the task is completed from the agent’s perspective. This is the main lifecycle hook for controlling “run until done” loops. [cursor](https://cursor.com/blog/agent-best-practices)

Payload shape:

```json
{
  "hook_event_name": "stop",
  "status": "completed",   // or "aborted", "error"
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

***

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

***

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

***

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

***

### 8.2 Run until tests pass with `stop`

Project `.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      { "command": "bun run .cursor/hooks/grind.ts" }
    ]
  }
}
```

`.cursor/hooks/grind.ts` implements:

- At `stop`:
  - Check external test status (for example, from a file or CI API)
  - If tests are failing and `loop_count < 5`, return a `followup_message` instructing the agent to keep fixing
  - Otherwise, return `{}` to allow the agent to end

Cursor’s own documentation and best‑practices guide highlight this “long‑running agent loop” pattern explicitly. [cursor](https://cursor.com/docs/cookbook/agent-workflows)

***

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

***

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

***

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

***

If you want, the next step can be to turn this into a concrete starter repository:

- `hooks/` with a Python or TS hook library
- A reusable `hooks.json` template
- A test harness that simulates hook payloads and validates your responses against the schemas above
