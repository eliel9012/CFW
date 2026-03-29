# Design System: The Digital Scriptorium

## 1. Overview & Creative North Star
**Creative North Star: "The Modern Archivist"**
This design system moves beyond a standard reading app to create a digital sanctuary for historical and religious study. It is inspired by the meticulous craftsmanship of ancient manuscripts and the refined elegance of modern academic journals. 

Instead of a "template" feel, this system breaks the grid with intentional editorial layouts. We achieve a premium, custom experience by using **asymmetric white space**, **overlapping typography**, and **tonal layering**. The interface should feel like fine vellum paper—tactile, deep, and quiet—allowing the weight of the historical text to remain the focal point.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a "Liturgical Academic" aesthetic, using high-contrast deep blues and aged golds to signify authority and reverence.

### The "No-Line" Rule
To maintain a high-end feel, **do not use 1px solid borders to define sections.** Boundaries must be established through background shifts. For example, a navigation sidebar should sit on `surface-container-low`, while the primary reading area rests on the `surface` background. This creates a "soft edge" that feels intentional rather than technical.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers of fine paper:
- **Base Layer:** `surface` (#fbf9f4) — The primary canvas.
- **Secondary Tier:** `surface-container-low` (#f5f3ee) — For subtle grouping of secondary information.
- **Emphasis Tier:** `surface-container-highest` (#e4e2dd) — For elevated UI elements like floating action bars or search modals.

### The "Glass & Gold" Rule
For iOS/iPadOS floating elements (e.g., navigation bars or context menus), use **Glassmorphism**. Apply a backdrop blur to a semi-transparent `surface-container-lowest` (#ffffff at 80% opacity). This allows the warm paper background to bleed through, softening the edges.

### Signature Textures
Main CTAs and Hero headers should use a **Subtle Radial Gradient** transitioning from `primary` (#031632) to `primary_container` (#1a2b48). This adds "soul" and depth, preventing the deep blues from feeling flat or "digital."

---

## 3. Typography: The Editorial Voice
We utilize a high-contrast pairing to distinguish between the "Timeless Text" (Serif) and the "Modern Toolset" (Sans-Serif).

*   **Headings (Newsreader):** Used for Display, Headline, and Title scales. This classic serif evokes the liturgical feel of a printed confession. Use `display-lg` for chapter starts to create an editorial, book-like entry point.
*   **Body (Newsreader):** Optimized for long-form reading. Use `body-lg` (1rem) for the main confession text to ensure maximum legibility during study.
*   **Utility (Inter):** Used for labels, buttons, and metadata. The transition to a clean Sans-Serif signals to the user that they are interacting with the "app" layer rather than the "document" layer.

---

## 4. Elevation & Depth
In this system, depth is a whisper, not a shout.

*   **Tonal Layering:** Instead of shadows, stack containers. Place a `surface-container-lowest` card on a `surface-container-low` section to create a natural, "physical" lift.
*   **Ambient Shadows:** If a floating element (like a FAB) requires a shadow, use a large blur (20px+) with an extremely low opacity (4%-6%). The shadow color should be a tinted version of `on_surface` (#1b1c19) to mimic natural light falling on paper.
*   **The Ghost Border Fallback:** If a border is required for accessibility, use the `outline_variant` token at **20% opacity**. Never use a 100% opaque border.

---

## 5. Components & Primitives

### Buttons
*   **Primary:** A deep navy (`primary`) pill with `on_primary` text. Use the `xl` (0.75rem) roundedness for a modern iOS feel.
*   **Tertiary (The "Scholar" Button):** No background, `secondary` (#775a19) text in `label-md` (Inter), implying a discrete, academic interaction.

### Cards & Reading Lists
*   **The Divider Forbid:** Never use horizontal lines to separate list items. Use **Vertical Spacing** (Token `4` or `1.4rem`) or a subtle shift to `surface-container-low` on hover/selection to define boundaries.
*   **The Scriptorium Card:** Used for chapter previews. A `surface-container-lowest` background with a `secondary` gold accent bar (2px) on the leading edge.

### Discrete Icons
*   Use thin-line (0.5pt - 1pt) icons only. Icons should be tinted with `outline` (#75777e) to remain secondary to the text.

### Specialized App Components
*   **The Annotation Gutter:** A dedicated vertical space using `surface-container-lowest` for user notes, mirroring the margins of a study Bible.
*   **The Liturgical Header:** A large `display-md` title that shrinks into a standard iOS `inline` title upon scroll, using a blur effect.

---

## 6. Do’s and Don’ts

### Do:
*   **Embrace Asymmetry:** Place the "Flame and Book" symbol off-center in hero headers to create an artisanal, high-end look.
*   **Use Generous Leading:** Increase line height for body text (use 1.6x) to facilitate "Deep Reading" sessions.
*   **Respect the "Fine Paper" Background:** Use `surface` as the default; only use pure white (`surface-container-lowest`) for elevated cards or glass effects.

### Don’t:
*   **Don't Use Pure Black:** Even for text, use `on_surface` (#1b1c19). Pure black is too harsh for the "Warm Paper" aesthetic.
*   **Don't Use Heavy Shadows:** They break the "Physical Paper" metaphor. Stick to tonal shifts.
*   **Don't Overuse Gold:** The `secondary` (Aged Gold) is an accent. Use it for links, active states, and symbols—not for large backgrounds.