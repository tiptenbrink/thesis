<script lang="ts">
  import Highlight from "./components/Highlight.svelte";

  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(4)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="text-present-title flex justify-center font-bold">Checking Pipeline</div>
  <div class="flex flex-col">
    <ul class="pl-5 mt-4 text-present">
      {#if animation > 0}
        <li class="mb-4">CP Solver outputs a proof log: will study it in a moment</li>
      {/if}
      {#if animation > 1}
        <li class="mb-4">Proof is processed and expanded for use</li>
      {/if}
      {#if animation > 2}
        <li class="mb-4">CP Proof Checker goes through the proof</li>
      {/if}
      {#if animation > 3}
        <li class="mb-4">Rejects or accepts: we want that if it accepts, proven that it is really valid</li>
      {/if}
    </ul>
  </div>
  
  <!-- <div class="font-bold text-present-title text-center flex justify-center items-center">
    Proof log
  </div>
  <div class="flex flex-col gap-8 items-center justify-center text text-present">
    <Highlight lang="txt" {code}></Highlight>
    <ul class="list-disc pl-5 mt-4">
      <li class="mb-4">Model, step 1, step 2, ..., step i → step i + 1</li>
      <li class="mb-4">Last step is conclusion</li>
    </ul>
  </div> -->
  
</div>

<style>
  li + li {
    margin-top: var(--present-bullet-margin);
  }
  .highlight {
    font-weight: bold;
    color: #ff6347; /* Tomato color */
  }
  .highlight2 {
    font-weight: bold;
  }

  .box {
    border: 2px solid #ff6347;
    padding: 1rem;
    margin-top: 2rem;
    border-radius: 8px;
  }
</style>