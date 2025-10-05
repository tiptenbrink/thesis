<script lang="ts">
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()
  import Highlight from "./components/Highlight.svelte";
  
  setLastAnimation(3)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;

  
</script>

<style>
  .highlight {
    font-weight: bold;
    color: #ff6347;
  }
  .nested {
      margin-left: 1.5rem;
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Certifying a Checker</div>
  <div class="flex flex-col text-present ml-8">
      <ul class="list-disc">
          <li>Before: Mathematical proof of correctness, manipulate proofs on computer</li>
          <li class:invisible={animation === 0}>My contribution: verifying single inferences, for example alldifferent</li>
          <li class:invisible={animation < 2}>Previous slide: {`|union of variable domains| < |variables|`}</li>
          <li class:invisible={animation < 3}>Final part: Let's prove it!</li>
      </ul>
  </div>
</div>