<script module>
  export const animations = 4
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="max-w-4xl mx-auto">
    <div class="space-y-6">
      {#if props.animation >= 1}
        <div class="bg-geel-muted rounded-lg p-6 shadow-md">
          <p class="text-present text-center font-medium">More than just <span class="bg-geel px-2 py-1 rounded font-bold">"implement"</span></p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="text-center mb-4">
          <p class="text-present">Standard development cycle:</p>
        </div>

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
      
      {#if props.animation >= 3}
        <div class="relative">
          <div class="absolute inset-0 rounded-2xl"></div>
          <div class="relative bg-white/90 backdrop-blur-sm rounded-2xl p-6 shadow-md">
            <p class="text-present text-center font-medium text-oranje">Problem: Never certain your program is fully correct</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>