<script lang="ts">
    import AllDiffSvg from "$lib/assets/AllDiffSvg.svelte";
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import Highlight from "./components/Highlight.svelte";
  
  setLastAnimation(2)

  const codeFn = `alldifferent_is_conflict(X, st)`
</script>

<style>
  .highlight {
    font-weight: bold;
    color: #ff6347;
  }
   .code {
    font-family: 'Courier New', Courier, monospace;
    background-color: #f0f0f0;
    padding: 0.5rem;
    border-radius: 4px;
    font-size: 1.1rem;
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Formalizing alldifferent</div>
  <div class="flex flex-col items-center text-present">
    {#if animation === 0}
      <div class="flex justify-center mt-4"><Highlight lang="coq" code={codeFn}></Highlight></div>
      <div>X: variables in constraint</div>
      <div>st: state, i.e. variable domains</div>
    {/if}
    {#if animation > 0}
      <div>X: variables in constraint</div>
      <div>st: state, i.e. variable domains</div>
      <div class="mt-6 w-[50vw]"><AllDiffSvg></AllDiffSvg></div>
    {/if}
    {#if animation > 1}
      <ul class="list-disc">
        <li>What is "correct"? Easy here, often difficult!</li>
      </ul>
    {/if}
  </div>
</div>