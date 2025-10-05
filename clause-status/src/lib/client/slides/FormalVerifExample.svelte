<script lang="ts">
  import AllDiffSvg from "$lib/assets/AllDiffSvg.svelte";
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import Highlight from "./components/Highlight.svelte";
  
  setLastAnimation(1)

  const coqCode = `Theorem all_different_sound : 
  forall (X : var_list) (st : state), alldifferent_is_conflict X st = true 
    -> 
  exists (x1 x2 : var) (n : Z), In x1 X /\\ In x2 X /\\ x1 <> x2 
    /\\ st x1 = fixed n /\\ st x2 = fixed n.
Proof.
  (* ... *)
Qed.`
</script>

<style>
  .code {
    font-family: 'Courier New', Courier, monospace;
    background-color: #f0f0f0;
    padding: 0.5rem;
    border-radius: 4px;
    font-size: 0.9rem; /* Smaller font for code */
  }
  .highlight {
    font-weight: bold;
  }
  .math-notation{
    font-size: 1.1rem;
    font-style: italic;
    margin-top: 0.5rem;
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="flex justify-center text-present-title font-bold">What does Roqc look like?</div>
  <div class="flex-col flex items-center">
    <div class="w-[70%]"><AllDiffSvg></AllDiffSvg></div>
    {#if animation > 0}
      <div class="text-present-small"><Highlight lang="coq" code={coqCode}></Highlight></div>
    {/if}
  </div>
  
</div>