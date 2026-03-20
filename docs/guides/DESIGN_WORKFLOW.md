# Design Workflow

Use this workflow when evolving the Taptime UI without losing consistency over
time.

## Working Files

- Web lab: `playgrounds/design-lab/`
- Reference metadata: `playgrounds/design-lab/references/manifest.js`
- Reference images: `playgrounds/design-lab/references/images/`
- Flutter theme target: `lib/core/theme/`

## Durable Design Data

Do not rely on browser state alone. Save these to git:

- approved screenshots
- source URLs for references
- manifest notes describing what must match
- exported token presets for approved directions

## Recommended Loop

1. Collect screenshots worth preserving
2. Save them in `playgrounds/design-lab/references/images/`
3. Register each one in `playgrounds/design-lab/references/manifest.js`
4. Tune tokens in the web lab until the direction feels right
5. Export the approved token JSON
6. Port the approved tokens into `lib/core/theme/`
7. Build Flutter screens against the saved screenshots and manifest notes

## Reference Quality Rules

- Save real screens, not just mood boards
- Prefer full-screen captures over tiny crops unless a detail is the point
- Write one clear takeaway per reference
- Note what may change and what must stay
- Keep only references you would actually implement from

## When Asking An Agent To Match A Capture

Provide one of:

- the exact image path in `playgrounds/design-lab/references/images/`
- the manifest entry title
- both, if several references are similar

Then specify:

- which screen should match it
- how strict the match should be
- what parts may differ because of product constraints
