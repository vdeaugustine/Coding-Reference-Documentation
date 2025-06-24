# Baseball Save-ant UI Design Language Guide

*Complete visual identity and implementation guide for creating consistent applications*

## Table of Contents
1. [Core Philosophy](#core-philosophy)
2. [Technology Stack](#technology-stack)
3. [Color System](#color-system)
4. [Typography](#typography)
5. [Visual Effects & Gradients](#visual-effects--gradients)
6. [Component Architecture](#component-architecture)
7. [Animation & Interactions](#animation--interactions)
8. [Layout & Spacing](#layout--spacing)
9. [Accessibility Standards](#accessibility-standards)
10. [Implementation Checklist](#implementation-checklist)

---

## Core Philosophy

The Baseball Save-ant design language embodies **modern minimalism with purposeful interactivity**. The visual identity emphasizes:

- **Dark-first design** with sophisticated contrast management
- **Glassmorphism effects** for depth and modern aesthetics
- **Teal-based brand identity** (#528E96) for trust and reliability
- **Accessibility-first** approach with high contrast and reduced motion support
- **Performance-optimized** animations and effects

---

## Technology Stack

### Required Dependencies
```json
{
  "tailwindcss": "^4",
  "@tailwindcss/postcss": "^4",
  "@headlessui/react": "^2.2.4",
  "@heroicons/react": "^2.2.0",
  "next": "^15.3.3",
  "typescript": "^5"
}
```

### PostCSS Configuration
```javascript
// postcss.config.mjs
const config = {
  plugins: ["@tailwindcss/postcss"],
};
export default config;
```

### Global CSS Setup
```css
/* globals.css */
@import "tailwindcss";

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);
  --font-mono: var(--font-geist-mono);
}
```

---

## Color System

### Primary Brand Colors
```css
:root {
  /* Core Brand Identity */
  --brand-primary: #528E96;        /* Main teal */
  --brand-secondary: #4ECDC4;      /* Hero accent teal */
  --brand-dark: #497f87;           /* Darker teal for gradients */
  
  /* Primary Color Scale */
  --color-primary-50: #f0fdfa;
  --color-primary-100: #ccfbf1;
  --color-primary-200: #99f6e4;
  --color-primary-300: #5eead4;
  --color-primary-400: #2dd4bf;
  --color-primary-500: #14b8a6;    /* Base teal */
  --color-primary-600: #0d9488;
  --color-primary-700: #0f766e;
  --color-primary-800: #115e59;
  --color-primary-900: #134e4a;
  --color-primary-950: #042f2e;
}
```

### Semantic Colors
```css
:root {
  /* Semantic Color System */
  --color-success: #22c55e;        /* Green */
  --color-warning: #eab308;        /* Amber */
  --color-error: #ef4444;          /* Red */
  --color-info: #3b82f6;           /* Blue */
}
```

### Grayscale Palette
```css
:root {
  /* Zinc-based Grayscale */
  --background: #0a0a0a;           /* Ultra dark background */
  --surface-1: #18181b;            /* Cards/containers */
  --surface-2: #27272a;            /* Elevated surfaces */
  --surface-3: #3f3f46;            /* Interactive elements */
  --border-subtle: #52525b;        /* Subtle borders */
  --text-primary: #ffffff;         /* Primary text */
  --text-secondary: #d4d4d8;       /* Secondary text */
  --text-muted: #a1a1aa;           /* Muted text */
}
```

### Usage Guidelines
```typescript
// Button States
className="bg-primary-600 hover:bg-primary-700 text-white"

// Text Colors
className="text-white"              // Primary text
className="text-gray-300"           // Secondary text  
className="text-gray-400"           // Muted text
className="text-teal-300"           // Brand accent text

// Background Colors
className="bg-zinc-900"             // Main background
className="bg-zinc-800"             // Card background
className="bg-zinc-700"             // Interactive background
```

---

## Typography

### Font Configuration
```typescript
// layout.tsx - Font Setup
import { Geist, Geist_Mono } from "next/font/google";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono", 
  subsets: ["latin"],
});
```

### Typography Scale
```css
/* Typography Hierarchy */
.text-hero {
  font-size: 3.75rem;              /* 60px - Hero headings */
  line-height: 1;
  font-weight: 800;
  background: linear-gradient(to right, #ffffff, #d1d5db);
  background-clip: text;
  color: transparent;
}

.text-heading-1 {
  font-size: 2.25rem;              /* 36px - Page headings */
  line-height: 1.2;
  font-weight: 700;
}

.text-heading-2 {
  font-size: 1.875rem;             /* 30px - Section headings */
  line-height: 1.3;
  font-weight: 600;
}

.text-body {
  font-size: 1rem;                 /* 16px - Body text */
  line-height: 1.5;
  font-weight: 400;
}

.text-caption {
  font-size: 0.875rem;             /* 14px - Captions */
  line-height: 1.4;
  font-weight: 400;
}
```

### Font Usage Patterns
```typescript
// Primary font for UI
className="font-sans text-white"

// Monospace for code/technical
className="font-mono text-gray-300"

// Brand gradient text
className="bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent"
```

---

## Visual Effects & Gradients

### Core Gradient Patterns
```css
/* Primary Brand Gradients */
.gradient-brand-primary {
  background: linear-gradient(135deg, #528E96, #497f87);
}

.gradient-brand-button {
  background: linear-gradient(to right, #528E96, #497f87);
}

.gradient-teal-button {
  background: linear-gradient(to right, rgb(13, 148, 136), rgb(15, 118, 110));
}

.gradient-hero-bg {
  background: linear-gradient(to bottom right, #000000, #18181b, #000000);
}

.gradient-header-text {
  background: linear-gradient(to right, #ffffff, #d1d5db);
  background-clip: text;
  color: transparent;
}

.gradient-user-avatar {
  background: linear-gradient(to bottom right, #4ECDC4, #3eb3a7);
}
```

### Glassmorphism Effects
```css
/* Core Glassmorphism Pattern */
.glass-primary {
  background: rgba(39, 39, 42, 0.6);        /* zinc-900/60 */
  backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 0.75rem;                    /* rounded-xl */
}

.glass-header {
  background: rgba(39, 39, 42, 0.8);        /* zinc-900/80 */
  backdrop-filter: blur(24px) saturate(180%);
  border-bottom: 1px solid rgba(82, 82, 91, 0.5);
}

.glass-card {
  background: rgba(39, 39, 42, 0.5);        /* zinc-800/50 */
  border: 1px solid rgba(82, 82, 91, 0.5);  /* zinc-700/50 */
  border-radius: 0.75rem;
}
```

### Shadow System
```css
/* Shadow Hierarchy */
.shadow-card {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1),
              0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.shadow-elevated {
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.shadow-focus {
  box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.5);  /* teal-500/50 */
}

.shadow-glow {
  box-shadow: 0 0 20px rgba(96, 165, 250, 0.2);
}
```

### Implementation Examples
```typescript
// Glassmorphism Card
<div className="bg-zinc-900/60 backdrop-blur-md border border-white/10 rounded-xl p-6">
  <h3 className="text-white font-semibold">Card Title</h3>
  <p className="text-gray-300">Card content</p>
</div>

// Gradient Button
<button className="bg-gradient-to-r from-teal-600 to-teal-700 hover:from-teal-700 hover:to-teal-800 text-white px-6 py-3 rounded-lg transition-all duration-200">
  Action Button
</button>

// Hero Text
<h1 className="text-6xl font-bold bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent">
  Hero Title
</h1>
```

---

## Component Architecture

### Design System Components

#### InfoBox Pattern
```typescript
interface InfoBoxProps {
  title: string;
  icon?: React.ReactNode;
  children: React.ReactNode;
  defaultOpen?: boolean;
  isOpen?: boolean;
  onToggle?: (isOpen: boolean) => void;
}

const InfoBox: React.FC<InfoBoxProps> = ({ 
  title, icon, children, defaultOpen, isOpen, onToggle 
}) => {
  // Supports both controlled and uncontrolled state
  const [internalIsOpen, setInternalIsOpen] = useState(defaultOpen ?? false);
  const actualIsOpen = isOpen !== undefined ? isOpen : internalIsOpen;
  
  return (
    <div className="bg-zinc-900/60 backdrop-blur-md border border-white/10 rounded-xl overflow-hidden">
      <button
        onClick={() => onToggle ? onToggle(!actualIsOpen) : setInternalIsOpen(!actualIsOpen)}
        className="w-full px-6 py-4 flex items-center justify-between text-left hover:bg-zinc-800/50 transition-colors"
      >
        <div className="flex items-center space-x-3">
          {icon}
          <h3 className="text-lg font-semibold text-white">{title}</h3>
        </div>
        <ChevronDownIcon className={`h-5 w-5 text-gray-400 transition-transform ${actualIsOpen ? 'rotate-180' : ''}`} />
      </button>
      
      {actualIsOpen && (
        <div className="px-6 pb-6 border-t border-zinc-700/50">
          <div className="pt-4 text-gray-300">
            {children}
          </div>
        </div>
      )}
    </div>
  );
};
```

#### Button Variants
```typescript
// Primary Button
const PrimaryButton = ({ children, isLoading, ...props }) => (
  <button
    className="bg-gradient-to-r from-teal-600 to-teal-700 hover:from-teal-700 hover:to-teal-800 disabled:from-zinc-600 disabled:to-zinc-700 text-white px-6 py-3 rounded-lg font-medium transition-all duration-200 flex items-center justify-center min-h-[44px]"
    disabled={isLoading}
    {...props}
  >
    {isLoading ? (
      <>
        <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/>
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
        </svg>
        Loading...
      </>
    ) : children}
  </button>
);

// Secondary Button
const SecondaryButton = ({ children, ...props }) => (
  <button
    className="bg-zinc-800 hover:bg-zinc-700 border border-zinc-600 text-gray-300 hover:text-white px-6 py-3 rounded-lg font-medium transition-all duration-200 min-h-[44px]"
    {...props}
  >
    {children}
  </button>
);
```

#### Card Pattern
```typescript
const Card = ({ children, variant = 'default', className = '' }) => {
  const variants = {
    default: "bg-zinc-800/50 border border-zinc-700/50",
    glass: "bg-zinc-900/60 backdrop-blur-md border border-white/10", 
    elevated: "bg-zinc-800 shadow-elevated"
  };
  
  return (
    <div className={`${variants[variant]} rounded-xl p-6 ${className}`}>
      {children}
    </div>
  );
};
```

---

## Animation & Interactions

### CSS Keyframes
```css
@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

@keyframes fadeIn {
  from { 
    opacity: 0; 
    transform: scale(0.95); 
  }
  to { 
    opacity: 1; 
    transform: scale(1); 
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes glow {
  0%, 100% { box-shadow: 0 0 5px rgba(96, 165, 250, 0.2); }
  50% { box-shadow: 0 0 20px rgba(96, 165, 250, 0.4); }
}
```

### Animation Utilities
```css
.animate-shimmer {
  animation: shimmer 2s linear infinite;
}

.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
}

.animate-slide-in {
  animation: slideIn 0.3s ease-out;
}

.animate-glow {
  animation: glow 2s ease-in-out infinite;
}
```

### Interaction Patterns
```typescript
// Standard Hover Effects
className="transition-all duration-200 hover:bg-zinc-800/70 hover:border-zinc-600/50 hover:scale-105"

// Focus States
className="focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2 focus:ring-offset-zinc-800"

// Loading States
className="animate-spin h-5 w-5 text-teal-500"

// Progress Animations
className="animate-pulse bg-teal-500/20"
```

### Timing Standards
- **Micro-interactions**: 100-200ms
- **Standard transitions**: 300ms
- **Modal animations**: 300ms enter, 200ms leave
- **Loading animations**: 2s infinite linear
- **Progress updates**: 100ms intervals

---

## Layout & Spacing

### Spacing Scale
```css
/* Consistent Spacing System */
.space-tight { gap: 0.5rem; }      /* 8px - Tight spacing */
.space-normal { gap: 1rem; }       /* 16px - Normal spacing */
.space-loose { gap: 1.5rem; }      /* 24px - Loose spacing */
.space-section { gap: 2rem; }      /* 32px - Section spacing */
.space-page { gap: 3rem; }         /* 48px - Page section spacing */
```

### Container Patterns
```typescript
// Page Container
<div className="min-h-screen bg-gradient-to-br from-black via-zinc-900 to-black">
  <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    {/* Page content */}
  </div>
</div>

// Card Grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {/* Cards */}
</div>

// Two-Column Layout
<div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
  {/* Content columns */}
</div>
```

### Responsive Breakpoints
- **sm**: 640px (Mobile landscape)
- **md**: 768px (Tablet)
- **lg**: 1024px (Desktop)
- **xl**: 1280px (Large desktop)
- **2xl**: 1536px (Extra large)

---

## Accessibility Standards

### Focus Management
```css
/* Focus Styles */
.focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px rgba(20, 184, 166, 0.5);
  border-color: rgba(20, 184, 166, 0.6);
}

/* High Contrast Support */
@media (prefers-contrast: high) {
  :root {
    --color-primary-500: #00ffff;
    --color-primary-600: #00cccc;
  }
}

/* Reduced Motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Touch Targets
```css
/* Mobile Touch Optimization */
@media (max-width: 640px) {
  button, a, input, select {
    min-height: 44px;
    min-width: 44px;
  }
  
  input[type="text"], input[type="url"], input[type="email"], select {
    font-size: 16px !important; /* Prevent zoom on iOS */
  }
}
```

### ARIA Patterns
```typescript
// Accessible Button with Loading State
<button
  className="..."
  disabled={isLoading}
  aria-disabled={isLoading}
  aria-describedby={isLoading ? "loading-description" : undefined}
>
  {isLoading ? (
    <>
      <span className="sr-only" id="loading-description">Loading, please wait</span>
      <LoadingIcon aria-hidden="true" />
      Loading...
    </>
  ) : (
    'Submit'
  )}
</button>
```

---

## Implementation Checklist

### Project Setup
- [ ] Install required dependencies (Tailwind v4, Headless UI, Heroicons)
- [ ] Configure PostCSS with Tailwind v4 plugin
- [ ] Set up Geist fonts with Next.js font optimization
- [ ] Configure CSS variables in globals.css
- [ ] Set up theme configuration in theme.ts

### Color Implementation
- [ ] Define primary brand color (#528E96) and scale
- [ ] Implement semantic color system
- [ ] Set up glassmorphism backdrop effects
- [ ] Configure gradient system
- [ ] Test high contrast mode support

### Component Library
- [ ] Create InfoBox collapsible component
- [ ] Implement button variants (primary, secondary, loading states)
- [ ] Build card component with glass/elevated variants
- [ ] Create modal system with Headless UI
- [ ] Implement progress tracking components

### Animation System
- [ ] Add shimmer keyframe animation
- [ ] Implement standard transition timings
- [ ] Create loading spinner components
- [ ] Set up progress bar animations
- [ ] Test reduced motion preferences

### Accessibility
- [ ] Implement focus management
- [ ] Add ARIA labels and descriptions
- [ ] Test keyboard navigation
- [ ] Verify color contrast ratios
- [ ] Test with screen readers
- [ ] Ensure 44px minimum touch targets

### Mobile Responsive
- [ ] Test all breakpoints (sm, md, lg, xl)
- [ ] Verify touch interactions
- [ ] Test iOS zoom prevention
- [ ] Validate scroll behavior
- [ ] Check mobile-specific optimizations

### Performance
- [ ] Optimize font loading
- [ ] Minimize animation JavaScript
- [ ] Test glassmorphism performance
- [ ] Verify CSS bundle size
- [ ] Test on low-powered devices

---

*This design language guide ensures consistent, accessible, and performant user interfaces across all Baseball Save-ant applications and future projects. Follow these patterns to maintain brand consistency and excellent user experience.*