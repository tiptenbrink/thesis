<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Limitations & Future Work</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="p-4 bg-koningsblauw text-white rounded-lg text-center">
        <p class="text-present font-bold">Empirical validation</p>
        <p class="text-present-small mt-1">Test proofs produced by CP solvers (now underway!)</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-bold">Performance optimizations</p>
        <p class="text-present-small mt-1">Apply solver algorithms/tricks to checker implementations</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="p-4 bg-paars text-white rounded-lg text-center">
        <p class="text-present font-bold">Solver hints + methodology expansion</p>
        <p class="text-present-small mt-1">Additional info to speed up checkers + help formal verification</p>
      </div>
    {/if}
  </div>
  
  {#if props.animation >= 0}
    <div class="text-center mt-6">
      <p class="text-present text-bordeaux font-semibold">Limitation: Higher formal verification burden compared to other approaches</p>
    </div>
  {/if}
</div>