<script module>
  export const animations = 7
</script>
<script lang="ts">
  let props: { animation: number } = $props()
</script>

<div class="h-full w-full p-6 flex flex-col justify-center">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-present-xl font-bold text-center mb-8 text-paars">But Wait...</h1>
    
    <div class="space-y-5">
      {#if props.animation >= 1}
        <div class="bg-geel-muted rounded-lg p-6 shadow-md">
          <p class="text-present text-center font-medium">How do we know the <em>proof checker</em> doesn't have similar mistakes?</p>
        </div>
      {/if}
      
      {#if props.animation >= 2}
        <div class="flex justify-center">
          <div class="bg-groen-muted rounded-lg p-3 shadow-md">
            <p class="text-present-small">✓ Checker is simpler than solver</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 3}
        <div class="flex justify-center">
          <div class="bg-bordeaux-muted rounded-lg p-3 shadow-md">
            <p class="text-present-small">✗ Still not simple enough</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 4}
        <div class="bg-koningsblauw-muted rounded-lg p-6 shadow-md">
          <p class="text-present text-center font-bold">Solution: Formal Verification</p>
        </div>
      {/if}
      
      {#if props.animation >= 5}
        <div class="text-center">
          <div class="inline-flex items-center space-x-3 bg-white/80 rounded-xl p-4 shadow-lg">
            <div class="w-8 h-8 bg-rounded-full flex items-center justify-center">
              <span class="font-bold text-sm">∀</span>
            </div>
            <p class="text-present-small">Mathematical specifications + formal proofs</p>
          </div>
        </div>
      {/if}
      
      {#if props.animation >= 6}
        <div class="flex justify-center">
          <div class="bg-donkergrijs-muted rounded-lg p-4 shadow-md">
            <div class="flex items-center space-x-3">
              <div class="flex items-center space-x-2">
                <div class="w-6 h-6 bg-koningsblauw rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">Us</span>
                </div>
                <span class="text-donkerblauw">→</span>
                <div class="w-6 h-6 bg-groen rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">Rocq</span>
                </div>
                <span class="text-donkerblauw">→</span>
                <div class="w-6 h-6 bg-oranje rounded-full flex items-center justify-center">
                  <span class="text-white text-xs font-bold">👥</span>
                </div>
              </div>
              <p class="text-present-small">Chain of trust</p>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>