# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Important**: Always use `pnpm`, never `npm`.

## Project Architecture

This is a SvelteKit presentation application that displays slides with animations and navigation controls.

### Core Structure

**Dynamic Routing**: Uses `[slide]/[animation]` route structure where:
- `slide` is the slide index (0-based)
- `animation` is the animation step within that slide (0-based)

**Slide System**: 
- Each slide is a Svelte component stored in `$lib/client/slides/`
- Slides must export an `animations` number (minimum 1) indicating animation steps and a default component
- Components receive an `animation` prop to control which animation step to show
- All slides are registered in `src/routes/[slide]/[animation]/slides.ts`

**Navigation**:
- Arrow keys, PageUp/Down navigate through animation steps
- 'a'/'d' keys jump between slides (to step 0)
- Automatic preloading of adjacent slides/animations for smooth navigation

**State Management**:
- Uses LMDB key-value store (`src/lib/server/kv.ts`) for server-side state persistence
- Database file: `kv.lmdb` in project root

### Key Files

- `src/routes/[slide]/[animation]/+page.svelte` - Main presentation viewer with keyboard navigation
- `src/routes/[slide]/[animation]/slides.ts` - Slide registry and type definitions  
- `src/lib/server/kv.ts` - LMDB key-value store wrapper
- Individual slide components in `src/lib/client/slides/`

### Adding New Slides

1. Create new slide component in `src/lib/client/slides/` with required module script:
   ```svelte
   <script module>
     export const animations = 1  // Number of animation steps (minimum 1)
   </script>
   ```
2. Import and add to slides array in `src/routes/[slide]/[animation]/slides.ts`:
   ```typescript
   import * as NewSlide from "$lib/client/slides/NewSlide.svelte";
   ```

### Styling

Uses Tailwind CSS v4 with custom presentation-specific font classes and TU Delft branding (tudelft.svg background).
- Always use the presentation notes to guide how slides should look like, feel free to update them if a slide becomes to tall, because there is only limited vertical space. Always summarize instructions and update presentation notes with generalizable lessons.
- Never use text-xl or similar for text size. Only use a limited set of global tailwind variables defined in app.css, so they can be changed if needed.

### How to make changes

First, make a todo list. Break down which slides must be edited. Try to work out the plan in more detail. Record this in `update.md`. You can always replace whatever was there previously. Then, execute the plan. Once you are done, compare what you have done with `update.md` and summarize your changes. Then, update `presentation-notes.md`, which is a complete overview of all design decisions and content for each slide, so that it is fully up to date. Furthermore, if there is anything in `finalpresentation.md` that is not clear in the presentation, mention that. 