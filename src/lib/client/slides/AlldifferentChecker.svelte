<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Alldifferent Checker</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 0}
      <div class="text-center">
        <p class="text-present-large">All variables must have distinct values</p>
        <p class="text-present text-gray-600 mt-2">Scheduling, assignments, puzzles</p>
      </div>
    {/if}
    
    {#if props.animation >= 1}
      <div class="p-5 bg-blue-50 rounded-lg text-center">
        <p class="text-present-large font-semibold text-blue-800">Key Tool</p>
        <p class="text-present mt-2">Hall's theorem provides theoretical foundation</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="text-center">
        <p class="text-present-large text-green-700 font-semibold">Complete verification</p>
        <p class="text-present text-gray-600 mt-2">Catches all valid propagations</p>
      </div>
    {/if}
  </div>
</div>