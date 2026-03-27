---
name: apple-progressive-disclosure
description: Design and implement Apple-style progressive disclosure via scrolling for web experiences. Use when building documentation/tutorial pages with sticky split-pane code reveal patterns, marketing/product pages with cinematic scroll storytelling, scroll-synced sticky media panels, IntersectionObserver-triggered section choreography, or when reducing cognitive load with one-idea-per-viewport information architecture.
---

# Apple Progressive Disclosure System

Use this skill to convert dense content into scroll-paced narrative where each scroll step delivers one new idea.

## Workflow
1. Define a scroll contract map before layout: list each section/step and one user takeaway per scroll step.
2. Choose a pattern:
- Use Anchored Code-Reveal for tutorials/docs.
- Use Cinematic Scroll-Storytelling for product/marketing pages.
3. Specify hierarchy for every section in this order: eyebrow, headline, body, big stat, detail.
4. Implement structure and motion:
- Use `position: sticky` for anchors (code/media).
- Use `IntersectionObserver` for step activation.
- Keep additive reveal behavior (build up, do not subtract).
5. Run anti-pattern audit before shipping and fix spec-dump, dual-load, orphaned animation, premature comparison.

## Required Outputs
When asked to design or implement with this skill, return:
- Scroll contract map (step -> single idea -> target emotion)
- Section hierarchy spec (eyebrow/headline/body/stat/detail per section)
- Annotated HTML outline (sticky, scroll-animated, additive markers)
- Anti-pattern audit with concrete fixes

## Resources
- Full implementation guide: [references/apple-progressive-disclosure.md](references/apple-progressive-disclosure.md)
- Skill icon asset: [assets/apple-computer-logo-rainbow.svg](assets/apple-computer-logo-rainbow.svg)
