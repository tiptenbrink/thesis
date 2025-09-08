<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-8">Our Approach</h1>
  
  <div class="grid grid-cols-2 gap-12">
    {#if props.animation >= 0}
      <div class="text-center">
        <h2 class="text-present-large font-semibold text-bosgroen mb-6">Our Focus</h2>
        <div class="space-y-4">
          <p class="text-present">Individual proof steps</p>
          <p class="text-present">Two key constraints:</p>
          <p class="text-present-small text-paars font-semibold">Alldifferent • Cumulative</p>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="text-center">
        <h2 class="text-present-large font-semibold text-oranje mb-6">Our Method</h2>
        <div class="space-y-4">
          <p class="text-present">Machine-checked proofs</p>
          <p class="text-present">Using Rocq theorem prover</p>
          <p class="text-present-small text-koningsblauw font-semibold">Highest trust</p>
        </div>
      </div>
    {/if}
  </div>
</div>