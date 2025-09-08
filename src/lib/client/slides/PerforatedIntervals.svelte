<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<!-- Progressive building layout -->
<div class="h-full w-full p-6">
  <h1 class="text-present-xl font-bold text-center mb-6">Perforated Intervals</h1>
  
  <!-- Side-by-side with progressive reveal -->
  <div class="grid grid-cols-2 gap-8 h-3/4">
    <!-- Left: Concept building -->
    <div class="flex flex-col justify-center space-y-4">
      {#if props.animation >= 0}
        <div class="p-4 bg-gray-50 rounded-lg">
          <p class="text-present-large font-semibold mb-2">The Problem</p>
          <p class="text-present-small">How to represent complex variable domains efficiently?</p>
        </div>
      {/if}
      
      {#if props.animation >= 1}
        <div class="p-4 bg-blue-50 rounded-lg">
          <p class="text-present-large font-semibold mb-2">Our Solution</p>
          <p class="text-present font-mono">[bounds] + {'{'}holes{'}'}</p>
          <p class="text-present-small mt-2 text-gray-600">Efficient representation for sparse domains</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="p-4 bg-purple-50 rounded-lg">
          <p class="text-present-large font-semibold mb-2">Tightness Theory</p>
          <p class="text-present-small">Formal conditions for when operations are efficient</p>
        </div>
      {/if}
    </div>
    
    <!-- Right: Visual examples -->
    <div class="flex flex-col justify-center space-y-6">
      {#if props.animation >= 1}
        <!-- Example visualization -->
        <div class="text-center">
          <p class="text-present font-semibold mb-4">Example</p>
          <div class="bg-white border-2 border-dashed border-gray-300 p-6 rounded">
            <p class="text-present-large font-mono">[1, 10] \ {'{'}3, 7, 8{'}'}</p>
            <p class="text-present-small text-gray-500 mt-3">represents</p>
            <p class="text-present text-gray-700">{'{'}1, 2, 4, 5, 6, 9, 10{'}'}</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <!-- Applications -->
        <div class="text-center">
          <p class="text-present font-semibold mb-3">Applications</p>
          <div class="space-y-2 text-present-small">
            <p>• Domain tracking in checkers</p>
            <p>• Foundation for domain maps</p>
            <p>• Efficient constraint reasoning</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>