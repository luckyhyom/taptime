# Design System Research

> **Researched:** 2026-03-14
> **Purpose:** Define visual direction and design framework for Taptime

## Design Framework Decision

Since Taptime uses **Flutter** (not web), CSS frameworks like Tailwind/shadcn don't apply directly. Instead, we use Flutter's built-in **Material 3 (Material You)** design system with heavy customization toward a minimal aesthetic.

### Why Material 3

- Built into Flutter — zero additional dependencies
- Supports dynamic color theming (2-3 color palette is trivial)
- Dark mode via `ThemeData` with automatic color scheme generation
- `ColorScheme.fromSeed()` generates a full palette from a single seed color
- Accessible by default (contrast ratios, touch targets)

### Customization Approach

- Strip Material 3 down to essentials — remove default elevation, reduce border radius variety
- Use `ThemeExtension` for app-specific design tokens
- Limit to 2-3 semantic colors, let Material generate shades

## Color Palette

### Chosen Palette: Deep Navy + Coral

Minimal, high-contrast, works well in both light and dark modes.

| Role | Light Mode | Dark Mode | Usage |
|------|-----------|-----------|-------|
| Primary | `#1A1A2E` (deep navy) | `#E8E8F0` (soft white) | Text, primary actions |
| Accent | `#E94560` (coral red) | `#E94560` (coral red) | Timer, active states, FAB |
| Surface | `#FAFAFA` (off-white) | `#16213E` (dark blue) | Backgrounds, cards |
| On-surface | `#333333` | `#CCCCCC` | Secondary text |

### Alternative Palettes Considered

| Name | Colors | Feel | Why not chosen |
|------|--------|------|----------------|
| Forest Green | `#2D6A4F` + `#95D5B2` | Calm, nature | Too similar to Forest app |
| Warm Sunset | `#FF6B35` + `#004E89` | Energetic | Orange can feel aggressive |
| Monochrome | `#000000` + `#FFFFFF` | Ultra-minimal | Too stark, no personality |

## Typography

- **Primary font:** System default (San Francisco on iOS, Roboto on Android)
- No custom fonts in MVP — reduces app size, maintains platform feel
- **Scale:** 3 sizes only — title (20sp), body (16sp), caption (12sp)

## Iconography

- Use **Material Icons** (built into Flutter)
- Preset icons: subset of ~20 curated icons relevant to common activities
- Consistent stroke weight, rounded style

### Preset Icon Set (MVP)

| Icon | Activity | Material Icon Name |
|------|----------|-------------------|
| Book | Study/Reading | `menu_book` |
| Dumbbell | Exercise | `fitness_center` |
| Code | Programming | `code` |
| Brush | Art/Design | `brush` |
| Music | Music/Practice | `music_note` |
| Language | Language study | `translate` |
| Work | General work | `work` |
| Meditation | Meditation | `self_improvement` |
| Writing | Writing/Journal | `edit_note` |
| Coffee | Break | `coffee` |

## Spacing & Layout

- **Grid:** 8px base unit
- **Card padding:** 16px
- **Screen margin:** 16px horizontal
- **Preset grid:** 2 columns, 12px gap
- **Border radius:** 12px (cards), 24px (buttons), 50% (FAB)

## Motion & Animation

- **MVP:** Flutter implicit animations only (`AnimatedContainer`, `AnimatedOpacity`)
- **Timer:** circular progress with `AnimationController` (smooth countdown)
- **Page transitions:** Material default slide/fade
- **Future:** Lottie animations for completion effects (v1.2)

## Design References

- [Material 3 Design Kit](https://m3.material.io/)
- [Material 3 Flutter Guide](https://docs.flutter.dev/ui/design/material)
