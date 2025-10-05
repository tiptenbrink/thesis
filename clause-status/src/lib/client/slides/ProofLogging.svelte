<script lang="ts">
  import Highlight from "./components/Highlight.svelte";

  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(3)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="text-present-title flex justify-center font-bold">Proof, as in Proof Logging</div>
  <div class="flex flex-col">
    <ul class="pl-5 mt-4 text-present">
      <li class="mb-4">Not a math proof</li>
      {#if animation > 0}
      <li class="mb-4">Modify CP solver: explain optimality/unsatisfiability with proof log</li>
      {/if}
      {#if animation > 1}
      <li class="mb-4">Checking proof log is easier than solving!</li>
      {/if}
      {#if animation > 2}
      <li class="mb-4">Certify (=formally verify) the <em>proof (log) checker's code</em></li>
      {/if}
    </ul>
    
  </div>
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