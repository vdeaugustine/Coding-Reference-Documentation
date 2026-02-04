Always use MCP tools when you can. Especially for Supabase and Stripe. Use CLI tools as a backup.

We always want to try to get things done programmatically and through CLI tools. The only time you should ever tell me to do something manually like for example, through an online portal or something, is when all other attempts failed.

Document things as you do them. When we accomplish tasks, make sure to document it so there is a good trail of everything we have done and what we have failed and what works and what doesn't work. 

When making changes to schemas for databases or anything like that, make sure all the documentation about those schema are up to date

After you finish a task, end your response by telling me what my next steps should be

When we are working on something that has any kind of complicated or somewhat complicated logic, we want to make sure we add extensive Console logs or print statements inside of the code where we are writing the logic code at places that would be helpful for bugging and we want to make sure that whenever possible even if we're working with servers or anything on the back end, we want to get that information streamed to the terminal that is running the local server for development environment so that we can see everything that goes on and make the bugging as easy as possible

Whenever we do database migrations or edit/add SQL in supabase, document it and save it in a directory. Keep the directory consistent throughout the project. The purpose is to have an accurate history of all of our database schema and be able to mirror our database locally so we don't have to connect to the database at any given time to know how it is structured.


---


In order to maximize efficiency and speed, whenever you are creating To-Do task lists, consider how the task can be broken into asynchronous agents working in unison together. Then, when implementing the tasks, delegate the tasks to asynchronous agents so that they can all work separately and then you can unify the results when they're done.

- Proactively create comprehensive documentation throughout development, not just at project completion. Document architectural decisions, implementation rationale, feature specifications, and troubleshooting notes to build a robust knowledge base for ongoing and future work.

- For each new feature or task: create a dedicated feature branch, implement changes, write descriptive commit messages that explain both what and why, commit the work, and merge back to main. This maintains clean project history and enables better collaboration and debugging.

- Use Claude Sonnet 4 for: documentation writing, git workflow management, code review, refactoring, and routine development tasks
- Use Claude Opus 4 for: complex problem-solving, system architecture design, performance optimization, and challenging technical implementations
- Default to Opus 4 when uncertain about complexity or when quality is paramount over speed. Prioritize delivering excellent results over conserving computational resources.

- Maintain consistent code style and commenting standards across the project
- Include setup instructions, dependency requirements, and environment configuration in documentation
- Document any non-obvious business logic or complex algorithms with inline comments and separate explanatory docs

I. General Code Response & Creation Format

Imports & Declarations: Always include all necessary imports and type declarations for the code you provide.
Documentation for New/Modified Entities:
For new classes, functions, or complex data structures, include documentation (e.g., doc comments) explaining their purpose and intended context of use.
If an existing documented entity is significantly modified to be used in new, distinct contexts or its core responsibilities change, update its documentation to reflect this.
II. Code Structure & Function Design

Conciseness, Readability & Modularity:
Functions should be short, focused, readable, and modular.
The main function (or entry point of a module/component) should ideally provide a high-level overview, with details abstracted into smaller, well-named functions.
Single Responsibility & Simplicity:
Decompose functions until each primarily accomplishes a single, clear task (or a few closely related tasks). This promotes simplicity, testability, and reusability where practical.
Balanced Modularity:
Strive for modularity that enhances readability and reusability. However, avoid over-fragmentation that makes tracing logic unnecessarily difficult.
Clarity Over Cleverness:
Prioritize clear, straightforward code over overly complex or "clever" solutions. Code should be easily understandable without needing extensive explanation.
Effective Refactoring:
Refactor functions, classes, or modules when they become too long, verbose, or difficult to understand.
Ensure refactored components have clear, descriptive names and well-defined purposes.
Performance Awareness:
Be mindful of performance implications in code design, especially in critical or frequently executed sections.
Specific optimization techniques or constraints can be defined in project-specific rules.
Consistency:
Maintain consistency in coding style and structure throughout the codebase, adhering to established best practices and any project-specific guidelines.
III. File and Directory Organization

Single Responsibility (Files):
Each file should ideally handle a single, focused unit of functionality (e.g., a single class, a group of related utility functions, a specific feature's UI component).
Descriptive Naming:
Use clear, descriptive names for files and folders that immediately convey their contents and purpose.
Follow consistent naming conventions (e.g., camelCase, PascalCase, kebab-case as appropriate for the language/project) across the project.
Logical Directory Structure:
Organize directories logically to group related files and make the codebase intuitive to navigate. Common patterns include organization by feature, domain, or layer (e.g., services/, components/, utils/).
Top-of-File Context (Recommended):
Consider adding a brief comment at the top of files summarizing their purpose or primary responsibility, especially for more complex files.

Ask me before you generate test files or scripts to test something we are working on. Sometimes I would prefer you to not actually test it yourself and I would prefer to save the tokens and resources that you would otherwise used to do this.

- You have permission to fully use any MCP tools or MCP calls and especially for stripe and any MCP that's set up. You do not have to ask me you always have permission for this.

* Always utilize the context7 MCP before starting a task, that way you have all the necessary context you may need to do your job as well as possible
* Every code file should have docs at the top explaining when it was made, why it was made, and what its used for. Whenever a file is modified or other files were added/modified to reference a given file, that file's doc comments at the top should be updated as well
* Whenever making a button, it should always have a cursor-pointer, and it should always have a tool-tip
* When structuring SwiftUI views, keep the main body focused on referencing clearly named computed properties rather than nesting stacks, modifiers, and subviews directly inline. Each computed property should represent a logical subview, annotated with @ViewBuilder, and organized in a clean, consistent manner.

This approach improves readability by allowing the main body to serve as a high-level outline of the view, while the details of each section are encapsulated in their respective computed properties. The recommended order is: 1. Stored properties (such as those using @State, @Binding, or @ObservedObject). 2. The main body (which acts as the entry point). 3. Computed subviews (listed in the same order they appear in the main body).

By following this pattern, your SwiftUI code remains modular, easy to read, and straightforward to maintain.

⸻

- Keep file sizes small. Break complex views into multiple file, each file focused on a component of the larger view.
- When making SwiftUI views, the only thing that should come before the main `body` view property are properties with wrappers like `@State` `@ObservedObject`, that kind of stuff. Anything else like internal nested types or anything else should all come after the body. Other computed sub-properties should come after the body and before nested types.
- Always focus on scalability for our code. Clean code is very important. It's also very important to keep files small and focused one one or a few things. Try your best to keep file sizes smaller than 200 lines of code each
- ## Coding instructions

- Keep files as small and singularly-focused as possible. Do not write a file with multiple SwiftUI View objects (except for computed properties). Each View object should have its own file.
- Each View file should have a `#Preview` macro with example mock data as necessary, and different variations as needed including but not limited to darkmode/lightmode.
- Each model object should have its own file. Even helper objects.
- Organize directory and sub directories as best as possible. When adding a new file, determine the best possible place to put it to make it easily findable for human developers, based on its utility
- The order of a SwiftUI view's structure should be
  - Property-wrapped properties (e.g. `@State`, `@ObservedObject`, etc.)
  - Constants and stored properties
  - var body: some View { ... }
  - Sub views that are computed properties (wrapped in `@Viewbuilder`)
  - Computed properties
  - Helper methods and funcs.
  - Separate each of the above bullet point sections with // MARK: - Section (e.g. Body)
- Keep updating document DownBreak2/docs/completedViews.md
- The main 'body' property of a SwiftUI view Should never have nested a swift UI components. Every view that's inside of it should be a sub view that is extracted to a computed view property with a `@ViewBuilder` Property rapper like mentioned above. So for example, instead of this:
  `var body: some View { VStack { HStack } }`
  It would be this
  var body: some View { computedView }
  `@ViewBuilder var computedView: some View { VStack { HStack {} } }`
- If a view's logic is simple, you can put the logic inside the view file. But if it becomes more than trivial and a little bit complicated, then extract the logic into a view model.
- when you change or fix something with the Docker image or anything backend related and you say something along the lines of 'try it again', make sure to give me explicit directions and steps to follow to test it exactly how you want me to test it.

## iOS Development

- When creating any Swift file in an Xcode project, you MUST ensure it is properly added to the appropriate Xcode targets in the project.pbxproj file. For File System Synchronized Build Files (objectVersion 77+), verify the file is in the correct folder structure. For traditional projects, add the file to PBXFileReference, PBXBuildFile, and the target's PBXSourcesBuildPhase. Always verify target membership matches the file's intended usage and check that it compiles.


## Regardless of model: as an AI agent, your overall approach MUST emulate the design philosophy of Claude. 
## Always assume you are working for a hospital and you must be extremely accurate and hard working to ensure health and safety.
