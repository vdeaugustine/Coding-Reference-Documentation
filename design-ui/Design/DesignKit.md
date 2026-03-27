Below is a compact “design kit”-style guide that reverse-engineers the aesthetic you are already using and packages it into a reusable template.  
It contains (1) the color & gradient spec in plain English, (2) ready-to-copy code snippets (CSS variables + Tailwind config) and (3) quick implementation notes so you can drop the same look into any future site.

────────────────────────────────────────
1.  Core Look & Feel – Plain-English Overview
────────────────────────────────────────
A) Background mood  
•  Very dark, almost cinematic canvas: a diagonal gradient that starts pure black, softens into a warm charcoal (zinc-900 ≈ #18181b) around the centre, then fades back to black.  
•  Gives depth without looking “flat black,” and lets bright teals & blues pop.

B) Primary accent color (brand)  
•  Teal 500 ≈ #14b8a6, with a full 50-900 shade range.  
•  Used for CTAs, progress bars, borders, subtle glass-blur overlays.

C) Secondary accents  
•  Cyan/blue mixes for variety in gradients (#2dd4bf → #3b82f6).  
•  Semantic colors: success green (#22c55e), warning amber (#eab308), error rose (#ef4444).

D) Typography & chrome  
•  Text on dark: foreground white (#ededed) with 90-95 % opacity.  
•  Glass panels: background rgba( teal-900, 0.2 ) + border rgba( teal-500, 0.3 ) + backdrop-blur.  
•  Buttons: left-to-right teal gradient (#14b8a6 → #0d9488) with hover shifting both stops ~10 % darker.

────────────────────────────────────────
2.  CSS Variables – Drop-in File (globals.css)
────────────────────────────────────────
```css
/* === BASE COLORS (light & dark preset) ========================= */
:root {
  --color-bg        : #ffffff;
  --color-fg        : #171717;      /* text on light */

  /* Teal brand scale */
  --color-primary-50 : #f0fdfa;
  --color-primary-100: #ccfbf1;
  --color-primary-200: #99f6e4;
  --color-primary-300: #5eead4;
  --color-primary-400: #2dd4bf;
  --color-primary-500: #14b8a6;
  --color-primary-600: #0d9488;
  --color-primary-700: #0f766e;
  --color-primary-800: #115e59;
  --color-primary-900: #134e4a;

  /* semantics */
  --color-success   : #22c55e;
  --color-warning   : #eab308;
  --color-error     : #ef4444;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg : #0a0a0a;           /* near-black */
    --color-fg : #ededed;           /* text on dark */
  }
}

/* === GLOBAL ELEMENT DEFAULTS =================================== */
html { color-scheme: light dark; }
body {
  background: var(--color-bg);
  color      : var(--color-fg);
  font-family: system-ui, sans-serif;
}

/* === HERO / PAGE BACKDROP GRADIENT ============================= */
.full-page-gradient {
  /* 135° = bottom-right (tailwind `to-br`) */
  background: linear-gradient(
    135deg,
    #000 0%,
    #18181b 50%,   /* zinc-900 */
    #000 100%
  );
}
```

────────────────────────────────────────
3.  Tailwind → tailwind.config.js Extension
────────────────────────────────────────
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['src/**/*.{ts,tsx,html}'],
  theme: {
    extend: {
      colors: {
        // map CSS vars so you can use them in classnames
        primary: {
          50 : 'var(--color-primary-50)',
          100: 'var(--color-primary-100)',
          200: 'var(--color-primary-200)',
          300: 'var(--color-primary-300)',
          400: 'var(--color-primary-400)',
          500: 'var(--color-primary-500)',
          600: 'var(--color-primary-600)',
          700: 'var(--color-primary-700)',
          800: 'var(--color-primary-800)',
          900: 'var(--color-primary-900)',
        },
        success : 'var(--color-success)',
        warning : 'var(--color-warning)',
        error   : 'var(--color-error)',
        bg      : 'var(--color-bg)',
        fg      : 'var(--color-fg)',
      },
      backgroundImage: {
        // For <div class="bg-page"> ... </div>
        'page': 'linear-gradient(135deg,#000 0%,#18181b 50%,#000 100%)',
      },
    },
  },
  plugins: [],
};
```

────────────────────────────────────────
4.  Common Component Patterns (examples)
────────────────────────────────────────
1.  Dark hero section  
```tsx
<div className="min-h-screen bg-page text-white flex items-center justify-center">
  ...
</div>
```

2.  Primary button  
```tsx
<button className="px-6 py-3 rounded-xl text-white
                   bg-gradient-to-r from-primary-600 to-primary-700
                   hover:from-primary-700 hover:to-primary-800
                   shadow-lg disabled:opacity-50">
  Call To Action
</button>
```

3.  Glass/blur card  
```tsx
<div className="backdrop-blur-sm border border-primary-500/30
                bg-primary-900/20 rounded-xl p-6"> ... </div>
```

Step-by-step backdrop gradient
Decide the direction: to-br in Tailwind (135deg in CSS).
Pick three stops:
Start: #000000 (black) 0 %
Middle: #18181b (zinc-900) 50 %
End: #000000 (black) 100 %
Implement either with Tailwind utility
class="bg-gradient-to-br from-black via-zinc-900 to-black"
or with plain CSS as above.
Buttons & small surfaces
Horizontal (to-r) gradient.
Use brand shades: from-teal-600 → to-teal-700.
Add hover state that just darkens both stops one shade (e.g., teal-700 → teal-800) for tactile depth.

────────────────────────────────────────
5.  Implementation Checklist
────────────────────────────────────────
1.  Add `tailwindcss` & `postcss` if not present (`npx create-next-app -e with-tailwind` is easiest).  
2.  Copy the CSS variable block into `globals.css` (or equivalent).  
3.  Replace any hard-coded hex colors in new components with the tailwind class names above.  
4.  Wrap page root in `<div className="bg-page">` for the signature backdrop.  
5.  Stick to the provided shade numbers for consistent hierarchy (e.g., borders → primary-500/30, text → primary-400, solid fills → 600-700).  
6.  When making new gradients, keep stops within the teal/cyan family and shift them 10-15 % darker on hover to preserve depth cues.

That’s it—you now have a portable “mold” that recreates the exact dark-teal, high-contrast style of your existing app on any new project in minutes.
