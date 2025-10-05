<script lang="ts">
  import Highlight from "./components/Highlight.svelte";

  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(4)

  const code = `A2 != 2\nA2 != 3\nA3 != 2\nUNSAT`;
</script>

<div class="grid grid-rows-[2fr_8fr] h-full w-full p-10">
  <div class="font-bold text-present-title text-center flex justify-center items-center">Certification</div>
  <div class="flex flex-col items-center text text-present">
    <ul class="list-disc">

        <li class:invisible={animation < 1} class="mb-4">Establish mathematical proof of correctness</li>


      <li class:invisible={animation < 2} class="mb-4">Proof on a computer, manipulate proofs with a programming language</li>

        <li class:invisible={animation < 3} class="mb-4">Something like a type checker ensures proofs are valid</li>

        <li class:invisible={animation < 4} class="mb-4">But what exactly am I verifying?</li>

      
    </ul>
      

      

<!-- 
    {#if animation > 4}
      <div class="flex justify-center text-present box">CP solvers use specialized reasoning for constraints; CP checkers also need to support them</div>
    {/if}  -->
    
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