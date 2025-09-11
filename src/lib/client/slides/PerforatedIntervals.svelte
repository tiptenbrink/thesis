<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-bosgroen">Perforated Intervals</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">Domain representation used throughout thesis</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-blue-50 rounded-lg text-center">
        <p class="text-present font-semibold text-koningsblauw">Structure:</p>
        <p class="text-present mt-2">Interval: [lower bound, upper bound] + holes (perforations)</p>
        <p class="text-present font-mono mt-2">[1, 10] \ {'{'}3, 7, 8{'}'}</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="w-full">
        <p class="text-present font-semibold text-center mb-4">Visual Example:</p>
        <div class="grid grid-cols-10 gap-2 max-w-4xl mx-auto">
          {#each Array(10) as _, i}
            <div class="aspect-square border-2 rounded-lg flex items-center justify-center text-present font-semibold
                        {props.animation >= 4 && [2, 6, 7].includes(i) ? 'bg-red-100 border-red-300 text-red-400 line-through opacity-50' : 'bg-koningsblauw text-white border-koningsblauw'}">
              {i + 1}
            </div>
          {/each}
        </div>
        {#if props.animation >= 4}
          <p class="text-present-small text-center mt-4 text-donkergrijs">
            Represents: {'{'}1, 2, 4, 5, 6, 9, 10{'}'}
          </p>
        {/if}
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-semibold">My contribution:</p>
        <p class="text-present-small mt-2">Formally verified + "tightness" condition for efficient min/max checking</p>
      </div>
    {/if}
  </div>
</div>