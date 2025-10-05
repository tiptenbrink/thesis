<script lang="ts">
  import Highlight from "./components/Highlight.svelte";

  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(2)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="text-present-title flex justify-center font-bold"></div>
  <div class="flex flex-col text-present">
    <div>Goals for this presentation:</div>
    <ul class="pl-5 mt-4 text-present">
      <li>Show how a CP Proof Checker really works</li>
      <li class:invisible={animation < 1}>Go in-depth on my contributions</li>
    </ul>


    {#if animation > 1}
      <div class="flex justify-center text-present box highlight">Now: checking problems with proof logs</div>
    {/if} 
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