<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Why Trust Matters in Optimization</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 0}
      <div class="text-center">
        <p class="text-present-large">Modern solvers tackle complex problems at incredible speed</p>
        <p class="text-present text-gray-600 mt-2">Healthcare • Circuits • Resources</p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="p-6 bg-blue-50 rounded-lg text-center">
        <p class="text-present-large font-semibold text-blue-800">The Challenge</p>
        <p class="text-present mt-2">When a solver says <strong>"impossible"</strong> — how do we know?</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large text-green-700 font-semibold">Solution: Proof-based verification</p>
        <p class="text-present text-gray-600 mt-2">Solvers explain their reasoning</p>
      </div>
    {/if}
  </div>
</div>