# App Development Workflow Guide

This document outlines the structured steps for going from idea to implementation when building apps. It ensures clarity, consistency, and efficiency across the entire development cycle.

---

## 0. Initial Brainstorming with AI

* **One-Shot Feature Listing**
  Begin by telling ChatGPT (or a similar AI assistant) what the app should do. List as many features and goals as possible in one attempt.
* **AI Clarification Loop**
  After your initial description, the AI tool should:

  * Ask clarifying questions about the app’s purpose, features, and user preferences.
  * Suggest additional functionality you might have overlooked.
  * Confirm your priorities (e.g., must-have vs. nice-to-have features).
* **Outcome**
  You will have a refined, clarified feature set and a more complete vision of the app.

---

## 1. Idea Generation and Preparation

* **List App Features**
  Write down all the app’s core features and potential enhancements (refined from Step 0).
* **Define Data Models**
  Identify the data structures (classes, structs, enums, etc.) needed.
* **App Summary**
  Draft a one-paragraph summary that captures the essence of the app. This provides context for any contributor or task worker.

---

## 2. High-Level View Planning

* **HighLevelViewFlow Document**
  Create a document listing every view in the app.

  * For each view, describe its *high-level responsibility*.
  * Keep the focus on the flow and responsibilities, not design or layout.

---

## 3. Detailed View Descriptions

* **Pick a View**
  Select one view from the HighLevelViewFlow.
* **Write Responsibilities**
  Document what the view should do, what it should display, and how the user should interact with it.

  * Avoid layout/design details.
  * Stay focused on functionality.
* **Repeat for All Views**
  Complete this step for every view.
* **Compile into ViewDescriptions Document**
  Save all detailed view write-ups into one reference document.

---

## 4. AI Prompt Creation for Views

* **Contextual Prompt Design**
  For each view, create a prompt for an AI tool that includes:

  1. The one-paragraph app summary (for context).
  2. Relevant data models or supporting structures.
  3. A clear description of what the view must do, show, and allow.
* **Goal**
  The prompt should be detailed enough for the AI to generate a usable, one-shot implementation of the view.
* **Repeat for All Views**
  Make unique prompts for each view.

---

## 5. Iteration and Integration

* Assemble AI-generated code for each view into the larger app.
* Validate that each view meets its documented responsibilities.
* Iterate as needed, refining both the code and the documentation.

---

✅ This workflow now starts with an **AI-powered brainstorming and clarification step** to capture your app idea as fully as possible before moving into structured planning.
