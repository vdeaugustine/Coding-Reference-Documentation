# Apple Progressive Disclosure: Web Design & Implementation System

This reference preserves the long-form implementation guidance for two Apple-inspired patterns:
- Anchored split-pane code reveal (developer tutorial style)
- Cinematic scroll storytelling (product page style)

## Core Philosophy
Use scrolling as a teaching instrument: one new idea, feeling, or visual reward per step.

Scroll contract rule:
For each step, explicitly name the one thing the user learns or feels.

## Pattern 1: Anchored Code-Reveal (Tutorial/Documentation)
Use a two-column layout where prose scrolls on the left and code/media stays sticky on the right.

### HTML Structure
```html
<div class="tutorial-layout">
  <div class="tutorial-steps">
    <div class="tutorial-step" data-step="1">...</div>
    <div class="tutorial-step" data-step="2">...</div>
    <div class="tutorial-step" data-step="3">...</div>
  </div>
  <div class="tutorial-code-pane">
    <div class="code-window">
      <pre><code class="code-block" id="codeDisplay"></code></pre>
    </div>
  </div>
</div>
```

### CSS (Sticky Split Layout)
```css
.tutorial-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: start;
  max-width: 1200px;
  margin: 0 auto;
}

.tutorial-steps {
  padding: 0 48px 400px 48px;
}

.tutorial-code-pane {
  position: sticky;
  top: 80px;
  height: calc(100vh - 80px);
  display: flex;
  align-items: center;
  padding: 0 48px;
}

.tutorial-step {
  min-height: 60vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 48px 0;
  opacity: 0.4;
  transition: opacity 0.3s ease;
}

.tutorial-step.is-active {
  opacity: 1;
}
```

### JavaScript (IntersectionObserver Sync)
```javascript
const codeDisplay = document.getElementById("codeDisplay");
const steps = document.querySelectorAll(".tutorial-step");

const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      const stepNumber = parseInt(entry.target.dataset.step, 10);
      steps.forEach((s) => s.classList.remove("is-active"));
      entry.target.classList.add("is-active");
      renderCode(stepNumber);
    });
  },
  { threshold: 0.5, rootMargin: "0px 0px -20% 0px" }
);

steps.forEach((step) => observer.observe(step));
```

Teaching rhythm per step:
1. Orient: Name concept
2. Act: Show delta in code/media
3. Understand: Explain why it matters

## Pattern 2: Cinematic Scroll Storytelling (Product/Marketing)
Use a 4-act page arc:
1. Emotional hook hero
2. Highlights section
3. Full-height feature chapters
4. Comparison/spec close

### CSS (Cinematic Chapters)
```css
.feature-section {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 120px 48px;
}

.feature-section--dark {
  background: #000;
  color: #f5f5f7;
}

.feature-section--light {
  background: #f5f5f7;
  color: #1d1d1f;
}
```

### Scroll Fade-In Motion
```javascript
const sections = document.querySelectorAll(".feature-section, .highlights-section");
const sectionObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add("is-visible");
      sectionObserver.unobserve(entry.target);
    });
  },
  { threshold: 0.15 }
);
sections.forEach((el) => sectionObserver.observe(el));
```

## Universal Rules
1. One idea per viewport
2. Anchor before advancing
3. Emotion before explanation
4. Big numbers stand alone
5. Never orphan the user
6. Earn complexity late
7. Additive reveal, not subtractive reveal

## Anti-Patterns to Catch
- Spec dump near top
- Orphaned animation without prose
- Unlabeled dense copy
- Premature comparison table
- Endless same-looking sections
- Dual-load steps (action + rationale at once)

## Audit Checklist
- First viewport: one emotional idea only
- Highlights list appears early
- Every step has a named takeaway
- Largest stat is isolated and oversized
- Comparison/spec detail appears in final act
- Adjacent sections are visually distinct
- Sticky anchor in tutorial mode
- Scroll animations are context-labeled
- Progress feels finite (labels/steps/landmarks)
- Observer thresholds avoid dual activation
