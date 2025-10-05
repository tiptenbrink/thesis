<script>
    import Highlight from "./components/Highlight.svelte";
  import StaticGrid from "./components/StaticGrid.svelte";
    import StaticGridDel from "./components/StaticGridDel.svelte";
    import { defaultNoInf } from "./grids/gridConstants";
    import { inferences } from "./snippets/GridContent.svelte";

  let { notAllowed, gridInput, colorInput, knowledge, check, blockedInput, noInference, leftSide, inputNoInference, infStep } = $props();

  const inputNoInferenceRes = inputNoInference === undefined ? defaultNoInf : inputNoInference
</script>

{#snippet knowledgeCheck()}
<div class="flex flex-col pl-20 text-present-large gap-4 justify-center">
  {#if knowledge}
  <span>Knowledge:</span>
  <span class="text-present"><Highlight lang="txt" code={knowledge}></Highlight></span>
  {/if}
  <span>Checking:</span>
  {#if check}
    <span class="text-present"><Highlight lang="txt" code={check}></Highlight></span>
  {:else}
    <span></span>
  {/if}
</div>
{/snippet}

<div class="grid grid-cols-[2fr_3fr]">
  {#if leftSide !== undefined}
    {@render leftSide()}
  {:else if infStep !== undefined}
    {@render inferences(infStep)}
  {:else}
    {@render knowledgeCheck()}
  {/if}
  <div class="w-full flex items-center justify-center"><div class="w-[90%]"><StaticGridDel {notAllowed} {gridInput} {colorInput} {blockedInput} {noInference} inputNoInference={inputNoInferenceRes}></StaticGridDel></div></div>
</div>