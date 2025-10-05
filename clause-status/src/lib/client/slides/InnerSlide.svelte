<script lang="ts">
    import type { Snippet } from "svelte";

  interface Props {
    id: string
    shown: string,
    children: Snippet,
    wide?: boolean
  }

  let { id, shown, wide, children }: Props = $props()
</script>

{#if id === shown}
  {#if wide === true}
    {@render children()}
  {:else}
    <div class="grid grid-cols-[2fr_12fr_2fr] w-full h-full">
      <div class="bg-gray-white"></div>
      <div class="contents">{@render children()}</div>
      <div class="bg-gray-white"></div>
    </div>
  {/if}
{/if}