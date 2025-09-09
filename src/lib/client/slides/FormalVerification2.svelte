<script module>
  export const animations = 6
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center bg-gradient-to-br from-purple-50 via-white to-blue-50">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-present-xl font-bold text-center mb-8 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">But Wait...</h1>
    
    <div class="space-y-5">
      {#if props.animation >= 1}
        <div class="relative">
          <div class="absolute inset-0 bg-gradient-to-r from-yellow-300 to-red-300 rounded-2xl blur opacity-25"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-yellow-100">
            <p class="text-present text-center font-medium text-gray-700">How do we know the <em>proof checker</em> doesn't have similar mistakes?</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="flex justify-center">
          <div class="bg-gradient-to-r from-green-100 to-emerald-100 rounded-lg p-3 shadow-sm">
            <p class="text-present-small text-green-700">✓ Checker is simpler than solver</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="flex justify-center">
          <div class="bg-gradient-to-r from-orange-100 to-red-100 rounded-lg p-3 shadow-sm">
            <p class="text-present-small text-red-700">✗ Still not simple enough</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="relative">
          <div class="absolute inset-0 bg-gradient-to-r from-cyan-300 to-blue-300 rounded-2xl blur opacity-30"></div>
          <div class="relative bg-gradient-to-r from-cyan-50 to-blue-50 rounded-2xl p-6 shadow-xl border border-cyan-200">
            <p class="text-present text-center font-bold text-blue-800">Solution: Formal Verification</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 5}
        <div class="text-center">
          <div class="inline-flex items-center space-x-3 bg-white/80 rounded-xl p-4 shadow-lg">
            <div class="w-8 h-8 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center">
              <span class="text-white font-bold text-sm">∀</span>
            </div>
            <p class="text-present-small text-gray-700">Mathematical specifications + formal proofs</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 6}
        <div class="flex justify-center">
          <div class="bg-gradient-to-r from-slate-100 to-gray-100 rounded-xl p-4 shadow-lg">
            <div class="flex items-center space-x-3">
              <div class="flex items-center space-x-2">
                <div class="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">Us</span>
                </div>
                <span class="text-gray-400">→</span>
                <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">Rocq</span>
                </div>
                <span class="text-gray-400">→</span>
                <div class="w-6 h-6 bg-orange-500 rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">👥</span>
                </div>
              </div>
              <p class="text-present-small text-gray-600">Chain of trust</p>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>