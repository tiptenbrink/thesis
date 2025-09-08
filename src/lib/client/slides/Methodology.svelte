<script module>
  export const animations = 3
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <h1 class="text-present-xl font-bold text-center mb-6">Inference Checker Methodology</h1>
  
  {#if props.animation >= 0}
    <!-- Flow diagram style layout -->
    <div class="flex items-center justify-between mb-8">
      <div class="w-1/4 text-center">
        <div class="p-4 bg-blue-50 rounded-lg">
          <p class="text-present font-semibold text-blue-700">Study</p>
          <p class="text-present-small">Propagation algorithm</p>
        </div>
      </div>
      <div class="text-present-large text-gray-400">→</div>
      <div class="w-1/4 text-center">
        <div class="p-4 bg-purple-50 rounded-lg">
          <p class="text-present font-semibold text-purple-700">Identify</p>
          <p class="text-present-small">Conflict types</p>
        </div>
      </div>
      <div class="text-present-large text-gray-400">→</div>
      <div class="w-1/4 text-center">
        <div class="p-4 bg-green-50 rounded-lg">
          <p class="text-present font-semibold text-green-700">Build</p>
          <p class="text-present-small">Checker</p>
        </div>
      </div>
    </div>
  {/if}
  
  {#if props.animation >= 1}
    <div class="p-5 bg-yellow-50 rounded-lg text-center mb-6">
      <p class="text-present-large font-semibold text-orange-800">Key Insight</p>
      <p class="text-present mt-2">Checking <strong>conflicts</strong> is easier than checking specific propagations</p>
    </div>
  {/if}
  
  {#if props.animation >= 2}
    <div class="grid grid-cols-2 gap-6">
      <div class="text-center">
        <p class="text-present font-semibold text-blue-700">Systematic Process</p>
        <p class="text-present-small text-gray-600 mt-2">Reusable for any constraint</p>
      </div>
      <div class="text-center">
        <p class="text-present font-semibold text-purple-700">Extensible Framework</p>
        <p class="text-present-small text-gray-600 mt-2">Guides future implementations</p>
      </div>
    </div>
  {/if}
</div>