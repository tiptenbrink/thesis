<script module>
  export const animations = 2
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-8 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Cumulative Checker</h1>
  
  {#if props.animation >= 0}
    <div class="text-center mb-6">
      <p class="text-present-large">Resource capacity constraints over time</p>
      <p class="text-present text-gray-600 mt-2">Never exceed available capacity</p>
    </div>
    
    <div class="w-full h-20 bg-orange-100 rounded-lg flex items-center justify-center border-2 border-dashed border-orange-400 mb-6">
      <p class="text-present-small text-gray-600">FIGURE: Resource timeline</p>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="grid grid-cols-2 gap-8">
      <div class="text-center">
        <p class="text-present-large font-semibold text-purple-700">Method</p>
        <p class="text-present mt-2">Timetable reasoning</p>
      </div>
      
      <div class="text-center">
        <p class="text-present-large font-semibold text-green-700">Result</p>
        <p class="text-present mt-2">Methodology demonstration</p>
      </div>
    </div>
  {/if}
</div>