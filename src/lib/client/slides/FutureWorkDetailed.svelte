<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Future Work</h1>
  
  <div class="space-y-4">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">• Empirical testing with full checker</p>
        <p class="text-present text-donkergrijs-muted">(already underway!)</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large">• Performance optimizations</p>
        <p class="text-present text-donkergrijs-muted">Apply solver tricks to checker</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="text-center">
        <p class="text-present-large">• Solver "hints"</p>
        <p class="text-present text-donkergrijs-muted">Additional info to speed up checking</p>
      </div>
    {/if}
  </div>
</div>