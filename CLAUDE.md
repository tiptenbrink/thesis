# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- `pnpm dev` - Start development server with hot reloading
- `pnpm build` - Build for production
- `pnpm preview` - Preview production build locally
- `pnpm check` - Run Svelte type checking
- `pnpm check:watch` - Run Svelte type checking in watch mode

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