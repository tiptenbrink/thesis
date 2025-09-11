<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6 text-bosgroen">Tightness</h1>
  
  <div class="space-y-6">
    {#if props.animation >= 1}
      <div class="text-center">
        <p class="text-present-large">Condition for efficient min/max checking</p>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="p-4 bg-blue-50 rounded-lg text-center">
        <p class="text-present font-semibold text-koningsblauw">Definition:</p>
        <p class="text-present mt-2">A perforated interval is <strong>tight</strong> when it doesn't have a hole at one of the bounds</p>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="grid grid-cols-2 gap-6">
        <div class="p-4 bg-red-50 rounded-lg text-center">
          <p class="text-present font-semibold text-bordeaux">Not tight:</p>
          <p class="text-present font-mono mt-2">[1,3] \ {'{'}1{'}'}</p>
          <!-- <p class="text-present-small mt-2">Hole at bound → complex</p> -->
          <!-- <p class="text-present-small">Lower bound = 2 (need to think!)</p> -->
        </div>
        {#if props.animation >= 4}
          <div class="p-4 bg-green-50 rounded-lg text-center">
            <p class="text-present font-semibold text-bosgroen">Tight:</p>
            <p class="text-present font-mono mt-2">[1,2]</p>
            <!-- <p class="text-present-small mt-2">No holes at bounds → simple</p> -->
            <!-- <p class="text-present-small">Lower bound = 1 (obvious!)</p> -->
          </div>
        {/if}
      </div>
    {/if}
    
    {#if props.animation >= 5}
      <div class="p-4 bg-bosgroen text-white rounded-lg text-center">
        <p class="text-present font-semibold">When tight:</p>
        <p class="text-present mt-2">Min/max = just inspect interval bounds</p>
      </div>
    {/if}
  </div>
</div>