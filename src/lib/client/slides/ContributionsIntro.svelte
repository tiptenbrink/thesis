<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="text-center">
    <h1 class="text-present-xl font-bold mb-8 text-gray-800">My Contributions</h1>
    
    {#if props.animation >= 1}
      <div class="relative mb-6">
        <div class="absolute inset-0 bg-gradient-to-r from-blue-200 via-purple-200 to-green-200 rounded-full blur-xl opacity-30"></div>
        <div class="relative bg-white/80 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-gray-200">
          <p class="text-present-large font-semibold text-gray-700">Ready to explore my work?</p>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 2}
      <div class="mb-6">
        <div class="inline-block bg-gradient-to-r from-yellow-100 to-orange-100 rounded-xl p-4 shadow-md">
          <p class="text-present text-orange-700 font-medium">+ One major reveal ahead</p>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 3}
      <div class="grid grid-cols-2 gap-4 max-w-md mx-auto">
        <div class="h-12 bg-gradient-to-r from-blue-100 to-blue-200 rounded-lg flex items-center justify-center">
          <div class="w-3 h-3 bg-blue-400 rounded-full"></div>
        </div>
        <div class="h-12 bg-gradient-to-r from-purple-100 to-purple-200 rounded-lg flex items-center justify-center">
          <div class="w-3 h-3 bg-purple-400 rounded-full"></div>
        </div>
        <div class="h-12 bg-gradient-to-r from-green-100 to-green-200 rounded-lg flex items-center justify-center">
          <div class="w-3 h-3 bg-green-400 rounded-full"></div>
        </div>
        <div class="h-12 bg-gradient-to-r from-gray-100 to-gray-200 rounded-lg flex items-center justify-center">
          <div class="w-3 h-3 bg-gray-400 rounded-full"></div>
        </div>
      </div>
    {/if}
    
    {#if props.animation >= 4}
      <div class="mt-6">
        <p class="text-present-small text-gray-600 italic">Four foundations of verified proof checking</p>
      </div>
    {/if}
  </div>
</div>