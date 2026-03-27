***

# ChatGPT (chatgpt.com) — Design Language Document

## 1. Design Language Overview

ChatGPT's interface is a study in restrained, functional minimalism. The visual language prioritizes information density reduction — nearly every decoration that doesn't serve communication has been removed. The palette is an almost-monochromatic series of near-black and near-white neutrals, with a single warm green accent reserved exclusively for brand identity (the OpenAI/ChatGPT logo mark). The result communicates competence, focus, and accessibility without the flair of consumer lifestyle products. [chatgpt](https://chatgpt.com/)

The design system is built on Tailwind CSS utility classes mapped to a semantic token layer prefixed `--color-text-*`, `--color-bg-*`, and `--color-border-*`. It ships two complete themes — dark (default for most users, defaulting to system preference) and light — swapped via an `html.dark` / `html.light` class on the root element. The UI is overwhelmingly type-driven, with layout controlled by flexbox and a small set of gap/padding values rather than a traditional grid. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

***

## 2. Color System

### Core Palette (Dark Mode — Default)

| Token | Role | Hex | RGB | HSL |
|---|---|---|---|---|
| `--color-bg-primary` | Main app background | `#212121` | 33, 33, 33 | 0°, 0%, 13% |
| `--color-bg-secondary` | Sidebar background | `#171717` | 23, 23, 23 | 0°, 0%, 9% |
| `--color-bg-tertiary` | Hover state on sidebar items | `#2F2F2F` | 47, 47, 47 | 0°, 0%, 18% |
| `--color-bg-elevated` | Input field / composer background | `#2F2F2F` | 47, 47, 47 | 0°, 0%, 18% |
| `--color-bg-overlay` | Modal scrim | `rgba(0,0,0,0.5)` | — | — |
| `--color-text-primary` | Body text, headings | `#ECECEC` | 236, 236, 236 | 0°, 0%, 93% |
| `--color-text-secondary` | Sidebar chat titles, labels | `#B4B4B4` | 180, 180, 180 | 0°, 0%, 71% |
| `--color-text-tertiary` | Timestamps, model version label | `#8E8EA0` | 142, 142, 160 | 240°, 6%, 59% |
| `--color-text-on-dark` | Text inside dark button surfaces | `#FFFFFF` | 255, 255, 255 | — |
| `--color-border-default` | Dividers, input outlines | `rgba(255,255,255,0.1)` | — | — |
| `--color-border-focus` | Focused input ring | `rgba(255,255,255,0.25)` | — | — |
| `--color-accent-brand` | OpenAI logo mark, primary CTA | `#10A37F` | 16, 163, 127 | 162°, 82%, 35% |
| `--color-accent-brand-hover` | Hover on green CTA | `#0D9170` | 13, 145, 112 | 162°, 83%, 31% |
| `--color-state-error` | Error text / border | `#EF4444` | 239, 68, 68 | 0°, 83%, 60% |
| `--color-state-success` | Success states | `#22C55E` | 34, 197, 94 | 142°, 71%, 45% |
| `--color-state-warning` | Warning / caution | `#F59E0B` | 245, 158, 11 | 38°, 92%, 50% |

### Light Mode Overrides

| Token | Hex | RGB | HSL |
|---|---|---|---|
| `--color-bg-primary` | `#FFFFFF` | 255, 255, 255 | 0°, 0%, 100% |
| `--color-bg-secondary` | `#F7F7F8` | 247, 247, 248 | 240°, 5%, 97% |
| `--color-bg-tertiary` | `#EFEFEF` | 239, 239, 239 | 0°, 0%, 94% |
| `--color-bg-elevated` | `#FFFFFF` | 255, 255, 255 | — |
| `--color-text-primary` | `#0D0D0D` | 13, 13, 13 | 0°, 0%, 5% |
| `--color-text-secondary` | `#6E6E80` | 110, 110, 128 | 240°, 7%, 47% |
| `--color-text-tertiary` | `#8E8EA0` | 142, 142, 160 | 240°, 6%, 59% |
| `--color-border-default` | `rgba(0,0,0,0.1)` | — | — |

### Surface Hierarchy (Dark)

```
Base layer:     #171717  (sidebar, deepest)
Primary surface: #212121  (main content area)
Elevated:       #2F2F2F  (input box, hover states, cards)
Overlay:        rgba(0,0,0,0.5) (modal scrims)
```



***

## 3. Typography

### Font Families

ChatGPT uses **Söhne** (a proprietary Klim Type Foundry typeface, similar to Helvetica Neue) as its primary UI font, with **Söhne Mono** for code. These are self-hosted. The fallback stack degrades gracefully to system UI fonts. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

| Context | Family | Fallback Stack |
|---|---|---|
| UI / Body | `Söhne` | `ui-sans-serif, system-ui, -apple-system, sans-serif` |
| Code / Monospace | `Söhne Mono` | `ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace` |

### Type Scale

| Token | Size | Line Height | Weight | Letter Spacing | Usage |
|---|---|---|---|---|---|
| `--text-xs` | 11px | 16px | 400 | 0 | Timestamps, meta labels |
| `--text-sm` | 13px | 20px | 400 | 0 | Sidebar nav items, secondary UI copy |
| `--text-sm-medium` | 13px | 20px | 500 | 0 | Sidebar section headers ("GPTs", "Projects") |
| `--text-base` | 16px | 28px | 400 | 0 | Chat body prose, input field text |
| `--text-base-medium` | 16px | 28px | 500 | 0 | Button labels |
| `--text-lg` | 18px | 28px | 600 | -0.01em | Greeting headline ("Hey, Vinnie.") |
| `--text-xl` | 22px | 30px | 700 | -0.02em | Primary headings in modals / onboarding |
| `--text-2xl` | 28px | 36px | 700 | -0.02em | Marketing / landing page H1 (inferred) |
| `--text-code-sm` | 13px | 20px | 400 | 0 | Inline code |
| `--text-code-base` | 14px | 24px | 400 | 0 | Code block content |

- **Max prose width:** ~680px (`max-w-2xl` / `max-w-3xl` — approximately 65–72 characters per line for readability)
- **Heading alignment:** Left-aligned in chat; center-aligned in modal/onboarding contexts
- **Text rendering:** `-webkit-font-smoothing: antialiased` applied globally

 [gist.github](https://gist.github.com/alexchexes/d2ff0b9137aa3ac9de8b0448138125ce)

***

## 4. Spacing & Layout

### Base Unit

The spacing system uses an **8px base unit** with a 4px half-step for fine-grained adjustments. All values are derived from Tailwind's default spacing scale. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

### Spacing Scale

| Token | Value | Tailwind Equiv |
|---|---|---|
| `--space-1` | 4px | `p-1` |
| `--space-2` | 8px | `p-2` |
| `--space-3` | 12px | `p-3` |
| `--space-4` | 16px | `p-4` |
| `--space-5` | 20px | `p-5` |
| `--space-6` | 24px | `p-6` |
| `--space-8` | 32px | `p-8` |
| `--space-10` | 40px | `p-10` |
| `--space-12` | 48px | `p-12` |
| `--space-16` | 64px | `p-16` |

### Grid & Breakpoints

ChatGPT does not use a traditional column grid. Layout is purely flexbox-based with a sidebar + main-content split. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

| Breakpoint | Width | Behavior |
|---|---|---|
| `sm` | 640px | Mobile single-column; sidebar collapses to off-canvas drawer |
| `md` | 768px | Sidebar still hidden; modal widths expand |
| `lg` | 1024px | Sidebar becomes persistent; two-column layout |
| `xl` | 1280px | Chat area widens; prose container caps at ~680px |
| `2xl` | 1536px | No further layout changes; content stays centered |

### Key Layout Values

- **Sidebar width:** 260px (desktop persistent)
- **Chat prose max-width:** `max-w-3xl` = ~672px
- **Composer max-width:** `max-w-3xl` — matches prose
- **Section padding (desktop):** 48px top/bottom, 24px horizontal
- **Navbar height:** 56px (desktop), 52px (mobile)
- **Sidebar item padding:** 8px vertical, 12px horizontal

***

## 5. Elevation & Layering

ChatGPT uses elevation very sparingly. Surfaces are differentiated primarily through background color variation rather than shadows, consistent with its flat aesthetic. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

### Shadow Scale

| Level | Usage | Value |
|---|---|---|
| 0 (flat) | Sidebar, main content | `none` |
| 1 (subtle) | Composer input box | `0 0 0 1px rgba(255,255,255,0.08)` (inferred as border-based, not shadow) |
| 2 (popover) | Dropdown menus, context menus | `0 4px 16px rgba(0,0,0,0.4)` |
| 3 (modal) | Dialogs, full overlays | `0 8px 32px rgba(0,0,0,0.6)` |

### z-index Scale

| Layer | Value | Usage |
|---|---|---|
| Base | 0 | Main content |
| Sidebar | 10 | Persistent sidebar |
| Sticky nav | 20 | Top nav bar |
| Dropdown | 50 | Context menus, popovers |
| Modal backdrop | 100 | Scrim overlay |
| Modal dialog | 110 | Dialog panels |
| Toast | 200 | Notification toasts |

### Backdrop / Blur

- Modal backdrop: `backdrop-filter: blur(0)` — no blur, pure black scrim at 50% opacity
- No glassmorphism effects used in the main UI (contrast with some GPT store landing pages which may use subtle blur)

***

## 6. Border & Shape

ChatGPT uses **rounded, friendly corners** at small-to-medium radii. Nothing sharp, nothing overly pill-shaped except for specific badge-style elements. [gist.github](https://gist.github.com/alexchexes/d2ff0b9137aa3ac9de8b0448138125ce)

| Component | Border Radius |
|---|---|
| Buttons (primary, secondary) | `8px` |
| Buttons (pill / model selector) | `9999px` (full pill) |
| Input / Composer textarea | `16px` |
| Sidebar nav items | `8px` |
| Cards / GPT tiles | `12px` |
| Modals / Dialogs | `16px` |
| Tooltips | `6px` |
| Badges / tags | `4px` |
| Avatars | `50%` (circular) |
| Code blocks | `8px` |

### Border Styles

- Default dividers: `1px solid rgba(255,255,255,0.08)` (dark) / `1px solid rgba(0,0,0,0.08)` (light)
- Input focus: `1px solid rgba(255,255,255,0.25)` + soft outer glow `box-shadow: 0 0 0 2px rgba(255,255,255,0.08)`
- No border on sidebar navigation items by default; border appears on hover/active via background color change only

***

## 7. Iconography

### Icon Library

ChatGPT uses a **custom SVG icon set** — not Heroicons, Lucide, or Feather, though the style is closely related to Heroicons (2px stroke-width, rounded linecaps, 24x24 viewBox). Icons are rendered inline as SVGs or via a custom icon component. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

### Icon Sizes

| Context | Size |
|---|---|
| Sidebar nav icons | 18×18px |
| Toolbar / action icons | 20×20px |
| Button icon-only | 16×16px |
| Header / primary nav | 24×24px |
| Avatar fallback icon | 32×32px |

### Icon Behavior

- Icons inherit `currentColor` by default, inheriting text color of parent
- Active/selected state: icon color shifts to `--color-text-primary` from `--color-text-secondary`
- Icon + label gap: `8px` (`gap-2`)
- No icon animation except for the "generating" spinner (CSS rotation)

***

## 8. Motion & Animation

ChatGPT's animation philosophy is **utilitarian and brief**. Transitions exist to confirm state changes and prevent jarring jumps, not for delight or brand expression. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

### Transition Defaults

| Property | Duration | Easing |
|---|---|---|
| Color, background-color | `150ms` | `ease` (cubic-bezier(0.4, 0, 0.2, 1)) |
| Opacity | `150ms` | `ease` |
| Sidebar open/close | `200ms` | `ease-in-out` |
| Modal appear | `150ms` | `ease-out` (fade + subtle scale from 0.97 → 1.0) |
| Dropdown open | `100ms` | `ease-out` |
| Tooltip appear | `100ms` | `ease` |
| Skeleton shimmer | `1500ms` | `linear` (infinite loop) |

### Animation Patterns

- **Fade:** Used for modal overlays, tooltips, toast notifications
- **Slide:** Sidebar slides in from left on mobile (`transform: translateX(-100%)` → `translateX(0)`)
- **Scale:** Modals scale from `scale(0.97)` to `scale(1.0)` on open
- **Skeleton shimmer:** Gradient sweep left-to-right using `@keyframes shimmer`
- **Text streaming:** Character-by-character rendering of model output has no CSS animation — it is driven purely by JavaScript token streaming
- **Spinner:** Single rotating circle SVG, `animation: spin 1s linear infinite`

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
This is respected — all transitions and animations are effectively disabled for users with reduced motion preferences. [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

***

## 9. Component Specs

### Buttons

| Variant | Background | Text | Border | Hover BG | Radius | Padding |
|---|---|---|---|---|---|---|
| Primary (green) | `#10A37F` | `#FFFFFF` | none | `#0D9170` | 8px | `10px 20px` |
| Secondary (dark) | `#2F2F2F` | `#ECECEC` | `1px solid rgba(255,255,255,0.1)` | `#3A3A3A` | 8px | `10px 20px` |
| Ghost | transparent | `#ECECEC` | none | `rgba(255,255,255,0.06)` | 8px | `8px 12px` |
| Destructive | transparent | `#EF4444` | none | `rgba(239,68,68,0.1)` | 8px | `8px 12px` |
| Pill / Model selector | `#2F2F2F` | `#ECECEC` | `1px solid rgba(255,255,255,0.1)` | `#3A3A3A` | 9999px | `6px 14px` |
| Icon-only | transparent | `#8E8EA0` | none | `rgba(255,255,255,0.06)` | 8px | `8px` |

- **Font:** 14px / 500 weight
- **Focus state:** `outline: 2px solid rgba(255,255,255,0.3); outline-offset: 2px`
- **Disabled:** opacity 40%, cursor `not-allowed`, no pointer events

### Input Fields / Composer

The main chat composer is the most distinctive input:

- **Background:** `#2F2F2F`
- **Border:** `1px solid rgba(255,255,255,0.1)` at rest; `rgba(255,255,255,0.2)` on focus
- **Border radius:** `16px`
- **Padding:** `12px 16px`
- **Font:** 16px / 400 / `Söhne`
- **Placeholder color:** `--color-text-tertiary` (`#8E8EA0`)
- **Min height:** 52px; grows with content (auto-resize `textarea`)
- **Max height:** `~200px` before scroll activates
- **Send button:** Circular, 32×32px, `#FFFFFF` background (when content present) with right-arrow icon in `#000000`

### Navigation Bar (Sidebar)

- **Width:** 260px, fixed on desktop
- **Background:** `#171717`
- **Top section:** Logo + "New chat" button + Search
- **Nav item height:** 36px
- **Nav item padding:** `8px 12px`
- **Active item background:** `rgba(255,255,255,0.08)`
- **Hover item background:** `rgba(255,255,255,0.06)`
- **Section label:** 11px / 500 / uppercase / `--color-text-tertiary`
- **Mobile:** Full overlay drawer, slides from left, backdrop scrim

### Cards (GPT Tiles / Project Cards)

- **Background:** `#2F2F2F`
- **Border:** `1px solid rgba(255,255,255,0.08)`
- **Border radius:** `12px`
- **Padding:** `16px`
- **Hover:** Background shifts to `#383838`, border to `rgba(255,255,255,0.15)`
- **Shadow:** none (flat)

### Modals / Dialogs

- **Backdrop:** `rgba(0,0,0,0.5)` full-screen
- **Dialog background:** `#2F2F2F` (dark) / `#FFFFFF` (light)
- **Border radius:** `16px`
- **Border:** `1px solid rgba(255,255,255,0.1)`
- **Padding:** `24px`
- **Max width:** 480px (compact dialogs), 640px (settings)
- **Shadow:** `0 8px 32px rgba(0,0,0,0.6)`
- **Close button:** Icon-only `×` ghost button, top-right, 32×32px

### Tooltips

- **Background:** `#404040` (dark) / `#1A1A1A` (light appearance, inferred)
- **Text:** `#FFFFFF` / 12px / 400
- **Padding:** `4px 8px`
- **Border radius:** `6px`
- **Shadow:** `0 2px 8px rgba(0,0,0,0.4)`
- **Appear:** 100ms fade, no pointer events

### Badges / Tags

- **Background:** `rgba(255,255,255,0.08)`
- **Text:** `#B4B4B4` / 12px / 500
- **Padding:** `2px 8px`
- **Border radius:** `4px`
- **Pro badge:** Green background `#10A37F`, white text

### Avatars

- **User avatar:** Circular, 32px diameter; photo if set, else initials on a colored background
- **Model avatar (ChatGPT):** Black circle, 32px, with white OpenAI "⬡" mark centered
- **Border:** None
- **Font for initials:** 13px / 600 / white

### Loading States

- **Spinner:** 20px SVG circle, stroke `#8E8EA0`, `stroke-dasharray`, 1s linear infinite rotation
- **Skeleton:** Rounded rectangles, `#2F2F2F` base with shimmer animation moving left-to-right at `rgba(255,255,255,0.04)` peak
- **Streaming cursor:** Blinking `|` character, `0.6s ease-in-out` blink

### Code Blocks

- **Background:** `#0D0D0D` (dark mode) — noticeably darker than the content surface
- **Border radius:** `8px`
- **Font:** `Söhne Mono` / 13px / 400
- **Syntax highlighting:** Uses a custom theme with muted, desaturated colors (strings in `#CE9178`, keywords in `#569CD6`, comments in `#6A9955` — visually similar to VS Code Dark+)
- **Header bar:** `#1A1A1A` with language label (`#8E8EA0`, 12px) and "Copy code" button (ghost, right-aligned)
- **Padding:** `16px`
- **Line height:** `1.625` (26px at 16px base)

 [chatgpt](https://chatgpt.com/)

***

## 10. Design Patterns

### Aesthetic Direction

**Refined functional minimalism.** No gradients, no illustrations, no decorative graphics in the primary UI. Color is used exclusively for information (green = OpenAI brand / success, red = error, gray scale = content hierarchy). The design communicates: "the model's output is the product; everything else steps aside." [community.openai](https://community.openai.com/t/customize-your-interface-for-chatgpt-web-custom-css-inside/315446)

### Whitespace

**Generous.** The main chat area has large vertical breathing room between messages. The sidebar is dense but not crowded — items are compact (36px tall) with clear categorical separation via section labels and subtle dividers.

### Visual Hierarchy

Three-level hierarchy enforced consistently:
1. **Primary:** `#ECECEC` — the content the user is reading
2. **Secondary:** `#B4B4B4` — navigation, labels, supporting copy
3. **Tertiary:** `#8E8EA0` — metadata, timestamps, disabled states

### Interaction Feedback

- **Hover:** Background color shifts, no scale transforms on desktop
- **Active/Pressed:** Background slightly darker than hover
- **Focus:** White outline ring (2px, offset 2px)
- **Selected/Active nav item:** Persistent background fill

### Brand Personality

The design communicates **trustworthy utility** — like a very well-made tool that never gets in your way. It borrows aesthetic language from developer tools and terminal interfaces (dark-first, monospace code blocks, muted palette) while remaining consumer-accessible through generous sizing and rounded forms. [chatgpt](https://chatgpt.com/)

***

## 11. Full CSS Token Reference

```css
:root {
  /* =====================
     COLOR — PRIMITIVES
  ===================== */
  --palette-black: #000000;
  --palette-white: #FFFFFF;
  --palette-gray-50: #F7F7F8;
  --palette-gray-100: #EFEFEF;
  --palette-gray-200: #D9D9D9;
  --palette-gray-300: #B4B4B4;
  --palette-gray-400: #8E8EA0;
  --palette-gray-500: #6E6E80;
  --palette-gray-600: #404040;
  --palette-gray-700: #2F2F2F;
  --palette-gray-800: #212121;
  --palette-gray-900: #171717;
  --palette-gray-950: #0D0D0D;
  --palette-green-400: #34D399;
  --palette-green-500: #10A37F;
  --palette-green-600: #0D9170;
  --palette-red-500: #EF4444;
  --palette-yellow-500: #F59E0B;
  --palette-blue-500: #3B82F6;

  /* =====================
     COLOR — SEMANTIC (DARK MODE DEFAULT)
  ===================== */
  --color-bg-primary: #212121;
  --color-bg-secondary: #171717;
  --color-bg-tertiary: #2F2F2F;
  --color-bg-elevated: #2F2F2F;
  --color-bg-hover: rgba(255, 255, 255, 0.06);
  --color-bg-active: rgba(255, 255, 255, 0.08);
  --color-bg-overlay: rgba(0, 0, 0, 0.5);
  --color-bg-code: #0D0D0D;
  --color-bg-code-header: #1A1A1A;

  --color-text-primary: #ECECEC;
  --color-text-secondary: #B4B4B4;
  --color-text-tertiary: #8E8EA0;
  --color-text-on-accent: #FFFFFF;
  --color-text-link: #10A37F;
  --color-text-error: #EF4444;
  --color-text-success: #22C55E;

  --color-border-default: rgba(255, 255, 255, 0.08);
  --color-border-subtle: rgba(255, 255, 255, 0.05);
  --color-border-strong: rgba(255, 255, 255, 0.2);
  --color-border-focus: rgba(255, 255, 255, 0.25);

  --color-accent-primary: #10A37F;
  --color-accent-primary-hover: #0D9170;
  --color-accent-secondary: rgba(16, 163, 127, 0.15);

  --color-state-error: #EF4444;
  --color-state-error-bg: rgba(239, 68, 68, 0.1);
  --color-state-success: #22C55E;
  --color-state-warning: #F59E0B;

  /* =====================
     TYPOGRAPHY
  ===================== */
  --font-sans: 'Söhne', ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  --font-mono: 'Söhne Mono', ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;

  --text-xs-size: 11px;
  --text-xs-line: 16px;
  --text-xs-weight: 400;

  --text-sm-size: 13px;
  --text-sm-line: 20px;
  --text-sm-weight: 400;

  --text-sm-medium-weight: 500;

  --text-base-size: 16px;
  --text-base-line: 28px;
  --text-base-weight: 400;

  --text-base-medium-weight: 500;

  --text-lg-size: 18px;
  --text-lg-line: 28px;
  --text-lg-weight: 600;
  --text-lg-tracking: -0.01em;

  --text-xl-size: 22px;
  --text-xl-line: 30px;
  --text-xl-weight: 700;
  --text-xl-tracking: -0.02em;

  --text-2xl-size: 28px;
  --text-2xl-line: 36px;
  --text-2xl-weight: 700;
  --text-2xl-tracking: -0.02em;

  --text-code-size: 13px;
  --text-code-line: 20px;
  --text-code-weight: 400;

  --text-code-block-size: 14px;
  --text-code-block-line: 24px;

  --prose-max-width: 672px;

  /* =====================
     SPACING
  ===================== */
  --space-0-5: 2px;
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;

  /* =====================
     LAYOUT
  ===================== */
  --sidebar-width: 260px;
  --navbar-height: 56px;
  --composer-radius: 16px;
  --content-max-width: 672px;
  --section-padding-x: 24px;
  --section-padding-y: 48px;

  /* =====================
     BORDER RADIUS
  ===================== */
  --radius-xs: 4px;
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-pill: 9999px;
  --radius-full: 50%;

  /* =====================
     ELEVATION / SHADOWS
  ===================== */
  --shadow-none: none;
  --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.4);
  --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.6);
  --shadow-input-focus: 0 0 0 2px rgba(255, 255, 255, 0.08);

  /* =====================
     Z-INDEX
  ===================== */
  --z-base: 0;
  --z-sidebar: 10;
  --z-sticky: 20;
  --z-dropdown: 50;
  --z-modal-backdrop: 100;
  --z-modal: 110;
  --z-toast: 200;

  /* =====================
     MOTION
  ===================== */
  --duration-fast: 100ms;
  --duration-base: 150ms;
  --duration-slow: 200ms;
  --duration-skeleton: 1500ms;
  --ease-default: cubic-bezier(0.4, 0, 0.2, 1);
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);

  /* =====================
     ICONS
  ===================== */
  --icon-xs: 14px;
  --icon-sm: 16px;
  --icon-md: 18px;
  --icon-lg: 20px;
  --icon-xl: 24px;
  --icon-gap: 8px;
}

/* =====================
   LIGHT MODE OVERRIDES
===================== */
html.light {
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F7F7F8;
  --color-bg-tertiary: #EFEFEF;
  --color-bg-elevated: #FFFFFF;
  --color-bg-hover: rgba(0, 0, 0, 0.04);
  --color-bg-active: rgba(0, 0, 0, 0.06);
  --color-bg-code: #F4F4F4;
  --color-bg-code-header: #E8E8E8;

  --color-text-primary: #0D0D0D;
  --color-text-secondary: #6E6E80;
  --color-text-tertiary: #8E8EA0;

  --color-border-default: rgba(0, 0, 0, 0.08);
  --color-border-subtle: rgba(0, 0, 0, 0.05);
  --color-border-strong: rgba(0, 0, 0, 0.2);
  --color-border-focus: rgba(0, 0, 0, 0.25);

  --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.12);
  --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.12);
  --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.18);
}
```
