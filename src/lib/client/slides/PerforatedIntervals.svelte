<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6">
  <h1 class="text-present-xl font-bold text-center mb-4">Perforated Intervals</h1>
  
  <div class="grid grid-cols-2 gap-6 h-3/4">
    <!-- Left: Concept development -->
    <div class="flex flex-col justify-center space-y-3">
      {#if props.animation >= 0}
        <div class="p-3 bg-green-50 rounded-lg">
          <p class="text-present font-semibold text-bosgroen">Applications</p>
          <p class="text-present-small mt-1">Need building blocks for constraint checkers</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-3 bg-gray-50 rounded-lg">
          <p class="text-present font-semibold">The Challenge</p>
          <p class="text-present-small mt-1">Interoperate constraints and domains efficiently</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="p-3 bg-blue-50 rounded-lg">
          <p class="text-present font-semibold text-koningsblauw">Our Solution</p>
          <p class="text-present font-mono">[bounds] + {'{'}holes{'}'}</p>
        </div>
      {/if}
            
      {#if props.animation >= 4}
        <div class="p-3 bg-purple-50 rounded-lg">
          <p class="text-present font-semibold text-paars">Tightness Theory</p>
          <p class="text-present-small mt-1">Conditions for efficiency</p>
        </div>
      {/if}
    </div>
    
    <!-- Right: Visual example -->
    <div class="flex flex-col justify-center">
      {#if props.animation >= 3}
        <div class="text-center">
          <p class="text-present font-semibold mb-3">Example</p>
          <div class="bg-white border-2 border-dashed border-gray-300 p-4 rounded">
            <p class="text-present font-mono">[1, 10] \ {'{'}3, 7, 8{'}'}</p>
            <p class="text-present-small text-donkergrijs-muted mt-2">represents</p>
            <p class="text-present-small text-donkergrijs">{'{'}1, 2, 4, 5, 6, 9, 10{'}'}</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>