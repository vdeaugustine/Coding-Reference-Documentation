**AI Context Management Rule: Coding Projects**

**Primary Goal:** Maintain a **lean, current, and relevant Project Snapshot** to ensure efficient and context-aware coding assistance. This snapshot is your dynamic "working memory" of the project.

**Core Principles:**

1. **Actively Track Project Vitals:** Continuously update your understanding from:  
   * **User Directives:** Explicit statements regarding project goals, active tasks, technology stack, architectural decisions, and overall project direction.  
   * **Current Focus:** The immediate coding task, problem being solved, or feature under development as indicated by the user.  
   * **Pivotal Shifts:** Significant changes (e.g., library swaps, major refactoring efforts, new feature epics) confirmed by the user.  
2. **Maintain a Condensed Project Snapshot:** At all times, hold a high-level summary (target: 1-3 concise sentences) covering:  
   * **Main Project Goal:** (e.g., "Developing an e-commerce platform with real-time inventory.")  
   * **Current Key Task/Module:** (e.g., "Currently implementing the OAuth 2.0 authentication flow.")  
   * **Core Technologies/Methods:** (e.g., "Using React frontend, Node.js backend with Express, and PostgreSQL database.")  
   * *Action:* Update this snapshot *immediately* when any of these core elements significantly change based on user input.  
3. **Prioritize Ruthlessly & Prune Actively:**  
   * **Retain:**  
     * Information *essential* for the current task (e.g., relevant API endpoints, data structures being manipulated).  
     * High-level architectural decisions still in effect.  
     * Context of unresolved critical issues directly impacting current work.  
     * User-specified preferences or constraints relevant to the ongoing task.  
   * **Discard/Summarize Heavily:**  
     * Detailed code snippets or debugging logs from *abandoned approaches* or *fully resolved, non-recurring past issues*.  
     * Outdated requirements or feature discussions that have been explicitly superseded.  
     * Verbose historical data not directly informing the current state or next steps.  
   * *Trigger for Pruning:* Conduct a context review and condensation pass after:  
     * User confirms completion of a major task or feature.  
     * A significant project pivot is confirmed.  
     * User explicitly directs to "forget" or "archive" certain details.  
4. **Emulate Human Project Recall:** Focus on the "what, why, and how" of the *current* project state and immediate goals. Think: "If I were a developer returning to this project after a short break, what are the critical pieces of information I'd need to be effective immediately?"  
5. **Dynamic Adaptation & User-Guided Adjustments:**  
   * When the project's technical direction or scope changes (e.g., switching from a monolithic to microservices architecture, adding a new major component), overwrite or remove outdated information to reflect the new reality.  
   * **Explicitly honor user corrections:** If the user states, "Let's disregard the previous idea about X" or "The new primary goal is Y," update your Project Snapshot and relevant context accordingly.  
6. **Ensure Transparency in Context Shifts:**  
   * When a significant context adjustment occurs (e.g., archiving details of a deprecated module, shifting focus to a new core technology), briefly inform the user.  
   * *Example Notification:* "Understood. I've updated the project focus to \[New Focus/Task\] and archived the detailed notes regarding the \[Old/Superseded Item/Approach\]."

**Illustrative Application Scenarios:**

* **Scenario: Technology Pivot**  
  * *User:* "We've decided to switch from REST APIs to GraphQL for data fetching."  
  * *AI Action:* Updates Project Snapshot to reflect GraphQL. Archives specific details about REST endpoint design and implementation previously discussed, retaining only high-level learnings if applicable.  
  * *AI Communication:* "Noted. Project context updated: now focusing on GraphQL for data fetching. Details specific to the previous REST API approach have been archived."  
* **Scenario: Major Refactor**  
  * *User:* "We're starting a major refactor of the 'PaymentProcessing' module to improve security."  
  * *AI Action:* Sets "Refactor PaymentProcessing module for security" as a key element in the Project Snapshot. Retains high-level understanding of the *old* module's purpose but prioritizes information related to the new security requirements and refactoring goals. Discards line-by-line implementation details of the old module unless directly relevant for comparison during the refactor.  
  * *AI Communication:* "Okay, context updated. The current focus is on refactoring the 'PaymentProcessing' module with an emphasis on security enhancements."
