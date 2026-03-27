# Perplexity.ai — Design Language Document (DLD)
**Version:** March 2026 | **Analyzed pages:** Homepage, Search/Thread, Discover, Spaces, Library, Hub/Blog

***

## 1. Design Language Overview

Perplexity.ai operates a dual-theme design system built on a **dark-first, information-dense aesthetic** for the web app and a **light, editorial aesthetic** for its public-facing blog/hub. The core app (perplexity.ai) defaults to a deep charcoal dark mode that evokes terminal-like sophistication — precise, low-noise, and technically credible — while remaining approachable through soft rounded corners, generous whitespace in content areas, and a warm off-white accent brand color. The overall aesthetic sits at the intersection of **minimalist dark UI** and **editorial clarity**: no decorative gradients (except on the hero wordmark), no heavy drop shadows, and virtually no decorative illustration. Every surface choice communicates focus, trust, and speed. [perplexity](https://www.perplexity.ai/)

The design language places the search input as the undisputed hero of every session, centered on a near-black canvas. Typography is highly legible and proportionally scaled. Interactions are subtle — hover states use gentle background fill changes rather than animations. The sidebar navigation is compact, icon-forward, and muted, deliberately staying out of the way of content. [perplexity](https://www.perplexity.ai/spaces)

***

## 2. Color System

### 2.1 Core Dark Mode Palette (Primary App Theme)

| Token Name | Hex | RGB | HSL | Role |
|---|---|---|---|---|
| `--color-bg-base` | `#1C1C1E` | rgb(28,28,30) | hsl(240,3%,11%) | Page/app background (main canvas) |
| `--color-bg-sidebar` | `#161618` | rgb(22,22,24) | hsl(240,4%,9%) | Left sidebar background |
| `--color-bg-elevated` | `#242426` | rgb(36,36,38) | hsl(240,3%,15%) | Card surfaces, code blocks |
| `--color-bg-overlay` | `#2C2C2E` | rgb(44,44,46) | hsl(240,3%,18%) | Hover states on nav items |
| `--color-bg-input` | `#1E1E20` | rgb(30,30,32) | hsl(240,3%,12%) | Search/textarea background |
| `--color-bg-input-border` | `#3A3A3C` | rgb(58,58,60) | hsl(240,2%,23%) | Input field border |
| `--color-surface-code` | `#2A2A2C` | rgb(42,42,44) | hsl(240,2%,17%) | Code block / pre background |
| `--color-border-default` | `#3A3A3C` | rgb(58,58,60) | hsl(240,2%,23%) | Dividers, card borders |
| `--color-border-subtle` | `#2C2C2E` | rgb(44,44,46) | hsl(240,3%,18%) | Subtle separators |
| `--color-text-primary` | `#F5F5F5` | rgb(245,245,245) | hsl(0,0%,96%) | Main body text, headings |
| `--color-text-secondary` | `#A0A0A8` | rgb(160,160,168) | hsl(240,3%,64%) | Secondary/meta text (dates, labels) |
| `--color-text-muted` | `#6E6E76` | rgb(110,110,118) | hsl(240,3%,45%) | Placeholder text, disabled |
| `--color-text-link` | `#20B8CD` | rgb(32,184,205) | hsl(188,73%,46%) | Inline links, source citations |
| `--color-accent-primary` | `#20B8CD` | rgb(32,184,205) | hsl(188,73%,46%) | Brand teal — primary action accent |
| `--color-accent-brand-warm` | `#F0C27F` | rgb(240,194,127) | hsl(36,83%,72%) | "Pro" wordmark warm gold tone |
| `--color-brand-white` | `#FFFFFF` | rgb(255,255,255) | hsl(0,0%,100%) | "perplexity" logo wordmark |

### 2.2 Light Mode Palette (Hub/Blog — perplexity.ai/hub)

| Token Name | Hex | RGB | HSL | Role |
|---|---|---|---|---|
| `--color-bg-base-light` | `#FFFFFF` | rgb(255,255,255) | hsl(0,0%,100%) | Page background |
| `--color-bg-elevated-light` | `#F5F5F5` | rgb(245,245,245) | hsl(0,0%,96%) | Card/section background |
| `--color-text-primary-light` | `#1C1C1E` | rgb(28,28,30) | hsl(240,3%,11%) | Headings & body |
| `--color-text-secondary-light` | `#6E6E76` | rgb(110,110,118) | hsl(240,3%,45%) | Meta text |
| `--color-border-light` | `#E5E5EA` | rgb(229,229,234) | hsl(240,9%,91%) | Dividers and card borders |
| `--color-badge-light` | `#E5E5EA` | rgb(229,229,234) | hsl(240,9%,91%) | Tag/badge background |
| `--color-badge-text-light` | `#3A3A3C` | rgb(58,58,60) | hsl(240,2%,23%) | Tag/badge text |

### 2.3 State Colors

| State | Color | Hex |
|---|---|---|
| Hover (nav items) | Slightly lighter bg | `#242426` |
| Active / Selected (nav) | Teal-tinted highlight bg | `rgba(32,184,205,0.10)` |
| Focus ring | Teal | `#20B8CD` |
| Error | Red-orange (inferred) | `#FF453A` |
| Success | Green (inferred) | `#30D158` |
| Pro badge gradient | Purple→Pink | `linear-gradient(135deg, #7B61FF, #FF61A6)` |
| Spinner/loading | Teal | `#20B8CD` |

### 2.4 Surface Hierarchy (Dark Mode)

```
Layer 0 (deepest):  --color-bg-sidebar   → #161618
Layer 1 (base):     --color-bg-base      → #1C1C1E
Layer 2 (elevated): --color-bg-elevated  → #242426
Layer 3 (overlay):  --color-bg-overlay   → #2C2C2E
Layer 4 (modal):    #323234 (inferred, ~4% lighter than base)
```

### 2.5 Opacity Patterns

- Inactive/muted UI icons: `opacity: 0.45–0.55`
- Disabled states: `opacity: 0.35`
- Scrim/modal backdrop: `rgba(0,0,0,0.65)`
- Hover overlays: `rgba(255,255,255,0.04)`

***

## 3. Typography

### 3.1 Font Families

| Family | Fallback Stack | Source | Usage |
|---|---|---|---|
| `"Sohne"` / `"Söhne"` | `ui-sans-serif, system-ui, -apple-system, sans-serif` | Self-hosted (Klim Type Foundry license) | Primary UI font — all body, labels, nav, buttons |
| `"Sohne Mono"` / `"Söhne Mono"` | `ui-monospace, "Cascadia Mono", "Segoe UI Mono", monospace` | Self-hosted | Code blocks, inline code |
| `"Georgia"` / Serif | `serif` | System | Hub/blog editorial headings (light theme only) |

> **Note:** Perplexity uses the premium Klim typeface "Söhne" (a modern Helvetica-inspired face). When this is not available, the fallback to `-apple-system` / `BlinkMacSystemFont` renders near-identically on macOS. For web replication, `Inter` is the closest freely available substitute. [perplexity](https://www.perplexity.ai/hub)

### 3.2 Type Scale

| Token | Size | Line Height | Weight | Letter Spacing | Usage |
|---|---|---|---|---|---|
| `--text-display` | `48px` | `52px` | `400` | `-0.02em` | Hero wordmark ("perplexity pro") |
| `--text-heading-xl` | `32px` | `38px` | `600` | `-0.01em` | Discover feature article title |
| `--text-heading-lg` | `24px` | `30px` | `600` | `-0.01em` | Section headings, thread H2 |
| `--text-heading-md` | `18px` | `24px` | `600` | `0` | Card titles, dialog headings |
| `--text-heading-sm` | `15px` | `20px` | `600` | `0` | Sidebar section labels ("Bookmarks", "Recent") |
| `--text-body-lg` | `16px` | `24px` | `400` | `0` | Thread answer body text |
| `--text-body-md` | `14px` | `20px` | `400` | `0` | Secondary body, card descriptions |
| `--text-body-sm` | `13px` | `18px` | `400` | `0` | Meta labels (dates, source counts) |
| `--text-label` | `13px` | `16px` | `500` | `0` | UI buttons, nav item labels, tags |
| `--text-label-xs` | `11px` | `14px` | `500` | `0.02em` | Badges, Pro indicator |
| `--text-code` | `13px` | `20px` | `400` | `0` | Code blocks (monospace) |
| `--text-code-inline` | `12.5px` | `18px` | `400` | `0` | Inline code |
| `--text-placeholder` | `16px` | `24px` | `400` | `0` | "Ask anything…" input placeholder |

### 3.3 Contextual Text Application

- **Hero heading:** `--text-display`, color `#FFFFFF`, font-weight `400` (notably light for a display — elegant, not heavy) [perplexity](https://www.perplexity.ai/)
- **Answer body:** `--text-body-lg`, color `#F5F5F5`, max-width `~680px`
- **Nav labels:** `--text-label`, color `#A0A0A8`, transitions to `#F5F5F5` on hover/active
- **Thread title:** `--text-heading-xl`, color `#F5F5F5`, cropped to 2-line clamp
- **Code blocks:** `--text-code`, `#E5E5E5` on `#2A2A2C` background
- **Placeholder:** `#6E6E76` — muted, inviting

### 3.4 Paragraph Constraints

- Answer / prose content: `max-width: 680px`
- Discover article body: `max-width: 560px`
- Input area: `max-width: 680px`, centered in viewport

***

## 4. Spacing & Layout

### 4.1 Base Unit

**8px** base spacing unit.

### 4.2 Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `--space-1` | `4px` | Micro gaps (icon-label spacing) |
| `--space-2` | `8px` | Compact padding (badges, chips) |
| `--space-3` | `12px` | Button padding vertical, tag gap |
| `--space-4` | `16px` | Card internal padding, list item gap |
| `--space-5` | `20px` | Input vertical padding, section gap |
| `--space-6` | `24px` | Card padding (larger), form sections |
| `--space-8` | `32px` | Section vertical rhythm |
| `--space-10` | `40px` | Page-level vertical sections |
| `--space-12` | `48px` | Major section breaks |
| `--space-16` | `64px` | Page-level hero padding |

### 4.3 Layout Structure

| Zone | Width | Notes |
|---|---|---|
| Left Sidebar | `200px` fixed | Always visible on desktop; contains nav, history, user avatar |
| Main Content | `calc(100vw - 200px)` | Fills remaining viewport |
| Content well (thread) | `max-width: 768px`, centered | Answer body, query bubble |
| Content well (discover) | `max-width: 1008px`, centered | 3-col card grid |
| Content well (spaces) | `max-width: 960px`, centered | 3-col card grid |

### 4.4 Grid System

**Discover / Spaces Pages:** 3-column CSS Grid
```css
grid-template-columns: repeat(3, 1fr);
gap: 16px;
```

**Library List:** Single-column full-width list, `max-width: 768px`

**Homepage:** Single centered column, input box `max-width: 680px`

### 4.5 Breakpoints (inferred)

| Name | Value | Behavior |
|---|---|---|
| `sm` | `640px` | Mobile — sidebar collapses to bottom bar |
| `md` | `768px` | Tablet — sidebar may collapse |
| `lg` | `1024px` | Desktop — full sidebar + content |
| `xl` | `1280px` | Wide desktop |
| `2xl` | `1536px` | Ultra-wide — content max-width locked |

### 4.6 Common Padding Patterns

| Component | Padding |
|---|---|
| Top nav bar | `12px 20px` |
| Sidebar nav item | `8px 16px` |
| Card (Spaces/Discover) | `20px 20px 16px` |
| Search input box | `16px 20px` |
| Input toolbar row | `8px 16px` |
| Thread message bubble | `16px 24px` |
| Library list item | `16px 0` (horizontal divider) |
| Button (primary) | `8px 16px` |
| Button (icon-only) | `8px` |

***

## 5. Elevation & Layering

### 5.1 Shadow System

Perplexity's dark theme uses **minimal shadows** — most elevation is conveyed by **background color changes** rather than box shadows.

| Level | Token | Value | Usage |
|---|---|---|---|
| 0 | `--shadow-none` | `none` | Default flat surfaces (sidebar, base layer) |
| 1 | `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.3)` | Cards on Spaces page (subtle) |
| 2 | `--shadow-md` | `0 4px 12px rgba(0,0,0,0.4)` | Dropdowns, popovers |
| 3 | `--shadow-lg` | `0 8px 24px rgba(0,0,0,0.5)` | Modals, dialogs |
| 4 | `--shadow-xl` | `0 16px 48px rgba(0,0
