<script lang="ts">
  let { setLastAnimation, animation }: { setLastAnimation: (n: number) => void, animation: number } = $props()

  setLastAnimation(4)
</script>

<style>
  li + li {
    margin-top: var(--present-bullet-margin);
  }
  .highlight {
    font-weight: bold;
    color: #ff6347; /* Tomato color */
  }

  .box {
    border: 2px solid #ff6347;
    padding: 0.5rem;
    margin-top: var(--box-margin);
    border-radius: 8px;
  }
</style>

<div class="grid grid-rows-[2fr_8fr] h-full w-full">
  <div class="font-bold text-present-title text-center flex justify-center items-center"></div>
  <div class="flex flex-col items-center text text-present">
    <ul class:invisible={animation === 0} class="list-disc">
      <li>We're all working on complex problems</li>
      <li class:invisible={animation < 2}>Complexity causes bugs</li>
      <li class:invisible={animation < 3}>Optimality/infeasibility is hard</li>
    </ul>
    {#if animation > 3}
      <div class="flex justify-center text-present box highlight">We want certainty that it really is optimal/infeasible!</div>
    {/if} 
  </div>
</div>