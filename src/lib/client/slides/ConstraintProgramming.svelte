<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-bosgroen">Constraint Programming (CP)</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">• Describes problems using general constraints</p>
        <p class="text-present-small text-donkergrijs-muted mt-2">(operations, jobs in factory, etc.)</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large">• Uses constraint-specific reasoning to solve them</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-semibold">Particularly successful in:</p>
        <p class="text-present mt-2">Scheduling problems (including healthcare)</p>
      </div>
    {/if}
  </div>
</div>