<script module>
  export const animations = 5
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-present-xl font-bold text-center mb-8 bg-gradient-to-r from-indigo-600 to-cyan-600 bg-clip-text text-transparent">An Important Fact</h1>
    
    <div class="space-y-6">
      {#if props.animation >= 1}
        <div class="relative">
          <div class="absolute inset-0 bg-gradient-to-r from-yellow-200 to-orange-200 rounded-2xl blur opacity-30"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-white/50">
            <p class="text-present text-center font-medium text-gray-700">I used the word <span class="bg-yellow-100 px-2 py-1 rounded font-bold text-yellow-800">"implemented"</span> quite a few times</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="text-center">
          <div class="inline-block bg-gradient-to-r from-blue-100 to-indigo-100 rounded-xl p-4 shadow-md">
            <p class="text-present text-indigo-700 font-medium">But this goes beyond just writing code</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="text-center mb-4">
          <p class="text-present-small text-gray-600">Traditional development cycle:</p>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="flex justify-center">
          <div class="bg-gradient-to-r from-slate-100 to-gray-100 rounded-xl p-4 shadow-lg border-l-4 border-slate-400">
            <div class="flex items-center space-x-4">
              <div class="flex space-x-2">
                <div class="w-3 h-3 bg-slate-400 rounded-full"></div>
                <div class="w-3 h-3 bg-slate-500 rounded-full"></div>
                <div class="w-3 h-3 bg-slate-600 rounded-full"></div>
              </div>
              <p class="text-present-small font-mono">Document → Code → Test → Repeat</p>
            </div>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 5}
        <div class="relative">
          <div class="absolute inset-0 bg-gradient-to-r from-red-200 to-pink-200 rounded-2xl blur opacity-30"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-red-100">
            <p class="text-present text-center font-medium text-red-700">Problem: Never certain your program is fully correct</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>