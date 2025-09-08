<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Constraint Checkers</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-6">
      <p class="text-present-large">We implemented checkers for two key constraint types:</p>
    </div>
  {/if}
  
  <div class="grid grid-cols-2 gap-8">
    {#if props.animation >= 1}
      <div class="p-4 bg-green-50 rounded-lg text-center">
        <p class="text-present-large font-bold text-bosgroen mb-2">Alldifferent</p>
        <p class="text-present-small">All variables must have distinct values</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-orange-50 rounded-lg text-center">
        <p class="text-present-large font-bold text-oranje mb-2">Cumulative</p>
        <p class="text-present-small">Resource capacity over time</p>
      </div>
    {/if}
  </div>
  
  {#if props.animation >= 2}
    <div class="text-center mt-6">
      <p class="text-present text-donkergrijs-muted">Both formally verified and demonstrate our systematic approach</p>
    </div>
  {/if}
</div>